local Buffer = require("lib/buffer")
local ForwardSearch = require("lib/motions/forward_search")

describe("ForwardSearch", function()
  it("has a name", function()
    assert.are.equals("forward_search", ForwardSearch:new().name)
  end)

  describe("#getRange", function()
    local cases = {
      {
        name = "next char from the start of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "x                          ",
        to   = "     x                     ",
      },
      {
        name = "next char from the middle of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "      x                    ",
        to   = "         x                 ",
      },
      {
        name = "next char if placed right after cursor",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "        x                  ",
        to   = "         x                 ",
      },
      {
        name = "skips char if placed on it",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "         x                 ",
        to   = "                   x       ",
      },
    }

    for _, case in ipairs(cases) do
      it(case.name, function()
        local buffer = Buffer:new()
        buffer:setValue(case.str)

        local indexFromRaw = case.from:find("x")
        local indexFrom = indexFromRaw - 1
        buffer:setSelectionRange(indexFrom, 0)

        local forwardSearch = ForwardSearch:new()
        forwardSearch:setExtraChar(case.char)

        local indexToRaw = case.to:find("x")
        local indexTo = indexToRaw - 1
        assert.are.same(
          {
            start = indexFrom,
            finish = indexTo,
            mode = "inclusive",
            direction = "characterwise"
          },
          forwardSearch:getRange(buffer)
        )
      end)
    end

    it("does nothing of no occurence found", function()
      local buffer = Buffer:new()
      buffer:setValue("just a word")

      buffer:setSelectionRange(2, 0)

      local forwardSearch = ForwardSearch:new()
      forwardSearch:setExtraChar("j")

      assert.is_nil(forwardSearch:getRange(buffer))
    end)
  end)
end)
