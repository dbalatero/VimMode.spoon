local Buffer = require("lib/buffer")
local CommandState = require("lib/command_state")
local TillBeforeSearch = require("lib/motions/till_before_search")

describe("TillBeforeSearch", function()
  it("has a name", function()
    assert.are.equals("till_before_search", TillBeforeSearch:new().name)
  end)

  describe("#getRange", function()
    local cases = {
      {
        name = "pre next char from the start of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "x                          ",
        to   = "    x                      ",
      },
      {
        name = "pre next char from the middle of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "      x                    ",
        to   = "        x                  ",
      },
      {
        name = "same char if target is placed right after cursor",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "        x                  ",
        to   = "        x                  ",
      },
      {
        name = "skips char if placed on it",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "         x                 ",
        to   = "                  x        ",
      },
    }

    for _, case in ipairs(cases) do
      it(case.name, function()
        local buffer = Buffer:new()
        buffer.vim = { commandState = CommandState:new() }

        buffer:setValue(case.str)

        local indexFromRaw = case.from:find("x")
        local indexFrom = indexFromRaw - 1
        buffer:setSelectionRange(indexFrom, 0)

        local tillBeforeSearch = TillBeforeSearch:new()
        tillBeforeSearch:setExtraChar(case.char)

        local indexToRaw = case.to:find("x")
        local indexTo = indexToRaw - 1
        assert.are.same(
          {
            start = indexFrom,
            finish = indexTo,
            mode = "inclusive",
            direction = "characterwise"
          },
          tillBeforeSearch:getRange(buffer)
        )
      end)
    end

    it("does nothing of no occurence found", function()
      local buffer = Buffer:new()
      buffer.vim = { commandState = CommandState:new() }

      buffer:setValue("just a word")

      buffer:setSelectionRange(2, 0)

      local tillBeforeSearch = TillBeforeSearch:new()
      tillBeforeSearch:setExtraChar("j")

      assert.is_nil(tillBeforeSearch:getRange(buffer))
    end)
  end)
end)
