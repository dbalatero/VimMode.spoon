local Buffer = require("lib/buffer")
local CommandState = require("lib/command_state")
local TillAfterSearch = require("lib/motions/till_after_search")

describe("TillAfterSearch", function()
  it("has a name", function()
    assert.are.equals("till_after_search", TillAfterSearch:new().name)
  end)

  describe("#getRange", function()
    local cases = {
      {
        name = "after prev char from the end of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "                          x",
        to   = "                        x  ",
      },
      {
        name = "after prev char from the middle of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "        x                  ",
        to   = "      x                    ",
      },
      {
        name = "same char if target is placed right after cursor",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "          x                ",
        to   = "          x                ",
      },
      {
        name = "skips char if placed on it",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "                   x       ",
        to   = "          x                ",
      },
    }

    for _, case in ipairs(cases) do
      it(case.name, function()
        local buffer = Buffer:new()
        buffer.vim = { commandState = CommandState:new() }

        buffer:setValue(case.str)

        local indexFromRaw = case.from:find("x")
        local indexFrom = indexFromRaw - 1
        buffer:setSelectionRange(0, indexFrom)

        local tillAfterSearch = TillAfterSearch:new()
        tillAfterSearch:setExtraChar(case.char)

        local indexToRaw = case.to:find("x")
        local indexTo = indexToRaw - 1
        assert.are.same(
          {
            start = indexTo,
            finish = indexFrom,
            mode = "exclusive",
            direction = "characterwise"
          },
          tillAfterSearch:getRange(buffer),
          case.name
        )
      end)
    end

    it("does nothing of no occurence found", function()
      local buffer = Buffer:new()
      buffer.vim = { commandState = CommandState:new() }

      buffer:setValue("just a word")

      buffer:setSelectionRange(7, 0)

      local tillAfterSearch = TillAfterSearch:new()
      tillAfterSearch:setExtraChar("d")

      assert.is_nil(tillAfterSearch:getRange(buffer))
    end)
  end)
end)
