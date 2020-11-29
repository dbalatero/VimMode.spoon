local Buffer = require("lib/buffer")
local BetweenChars = require("lib/motions/between_chars")

describe("BetweenChars", function()
  it("has a name", function()
    assert.are.equals("between_chars", BetweenChars:new().name)
  end)

  describe("#getRange", function()
    it("returns nil if there is no between chars", function()
      local buffer = Buffer:new()
      buffer:setValue("html")
      buffer:setSelectionRange(0, 0)

      local betweenChars = BetweenChars:new()
      betweenChars:setSearchChars('<', '>')

      assert.are.same(nil, betweenChars:getRange(buffer))
    end)

    it("handles the left edge", function()
      local buffer = Buffer:new()
      buffer:setValue("<html>")
      buffer:setSelectionRange(0, 0)

      local betweenChars = BetweenChars:new()
      betweenChars:setSearchChars('<', '>')

      assert.are.same(
        {
          start = 1,
          finish = 4,
          mode = "inclusive",
          direction = "characterwise"
        },
        betweenChars:getRange(buffer)
      )
    end)

    it("handles the right edge", function()
      local buffer = Buffer:new()
      buffer:setValue("<html>")
      buffer:setSelectionRange(5, 0)

      local betweenChars = BetweenChars:new()
      betweenChars:setSearchChars('<', '>')

      assert.are.same(
        {
          start = 1,
          finish = 4,
          mode = "inclusive",
          direction = "characterwise"
        },
        betweenChars:getRange(buffer)
      )
    end)

    it("handles between the chars", function()
      local buffer = Buffer:new()
      buffer:setValue("<html>")
      buffer:setSelectionRange(3, 0)

      local betweenChars = BetweenChars:new()
      betweenChars:setSearchChars('<', '>')

      assert.are.same(
        {
          start = 1,
          finish = 4,
          mode = "inclusive",
          direction = "characterwise"
        },
        betweenChars:getRange(buffer)
      )
    end)
  end)
end)
