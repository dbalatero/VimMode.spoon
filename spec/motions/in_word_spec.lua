local Buffer = require("lib/buffer")
local InWord = require("lib/motions/in_word")

describe("InWord", function()
  it("has a name", function()
    assert.are.equals("in_word", InWord:new().name)
  end)

  describe("#getRange", function()
    it("handles the middle of the word", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(5, 0)

      local inWord = InWord:new()

      assert.are.same(
        {
          start = 4,
          finish = 6,
          mode = "inclusive",
          direction = "characterwise"
        },
        inWord:getRange(buffer)
      )
    end)

    it("handles the beginning of the buffer", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(0, 0)

      local inWord = InWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 2,
          mode = "inclusive",
          direction = "characterwise"
        },
        inWord:getRange(buffer)
      )
    end)

    it("handles the beginning of the word", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(4, 0)

      local inWord = InWord:new()

      assert.are.same(
        {
          start = 4,
          finish = 6,
          mode = "inclusive",
          direction = "characterwise"
        },
        inWord:getRange(buffer)
      )
    end)

    it("handles the end of the word", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(6, 0)

      local inWord = InWord:new()

      assert.are.same(
        {
          start = 4,
          finish = 6,
          mode = "inclusive",
          direction = "characterwise"
        },
        inWord:getRange(buffer)
      )
    end)

    it("handles the end of the buffer", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(12, 0)

      local inWord = InWord:new()

      assert.are.same(
        {
          start = 8,
          finish = 13,
          mode = "inclusive",
          direction = "characterwise"
        },
        inWord:getRange(buffer)
      )
    end)
  end)
end)
