local Buffer = require("lib/buffer")
local BackwardSearch = require("lib/motions/backward_search")

describe("BackwardSearch", function()
  it("has a name", function()
    assert.are.equals("backward_search", BackwardSearch:new().name)
  end)

  describe("#getRange", function()
    local cases = {
      {
        name = "prev char from the end of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "                          x",
        to   = "                       x   ",
      },
      {
        name = "prev char from the middle of the line",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "        x                  ",
        to   = "     x                     ",
      },
      {
        name = "prev char if placed right before cursor",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "          x                ",
        to   = "         x                 ",
      },
      {
        name = "skips char if placed on it",
        char = "o",
        str  = "cat dog mouse cat dog mouse",
        from = "                  x        ",
        to   = "         x                 ",
      },
    }

    for _, case in ipairs(cases) do
      it(case.name, function()
        local buffer = Buffer:new()
        buffer:setValue(case.str)

        local indexFromRaw = case.from:find("x")
        local indexFrom = indexFromRaw
        buffer:setSelectionRange(0, indexFrom)

        local backwardSearch = BackwardSearch:new()
        backwardSearch:setExtraChar(case.char)

        local indexToRaw = case.to:find("x")
        local indexTo = indexToRaw - 1
        assert.are.same(
          {
            start = indexTo,
            finish = indexFrom,
            mode = "exclusive",
            direction = "characterwise"
          },
          backwardSearch:getRange(buffer)
        )
      end)
    end

    it("does nothing of no occurence found", function()
      local buffer = Buffer:new()
      buffer:setValue("just a word")

      buffer:setSelectionRange(7, 0)

      local backwardSearch = BackwardSearch:new()
      backwardSearch:setExtraChar("d")

      assert.is_nil(backwardSearch:getRange(buffer))
    end)
  end)
end)
