local Buffer = require("lib/buffer")
local EndOfWord = require("lib/motions/end_of_word")

describe("EndOfWord", function()
  it("has a name", function()
    assert.are.equals("end_of_word", EndOfWord:new().name)
  end)

  describe("#getRange", function()
    it("handles simple words", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(0, 0)

      local endOfWord = EndOfWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 2,
          mode = "inclusive",
          direction = "characterwise"
        },
        endOfWord:getRange(buffer)
      )
    end)

    it("goes to the next word end", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(2, 0)

      local endOfWord = EndOfWord:new()

      assert.are.same(
        {
          start = 2,
          finish = 6,
          mode = "inclusive",
          direction = "characterwise"
        },
        endOfWord:getRange(buffer)
      )
    end)

    it("stops on new lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat\nmouse")
      buffer:setSelectionRange(0, 0)

      local endOfWord = EndOfWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 2,
          mode = "inclusive",
          direction = "characterwise"
        },
        endOfWord:getRange(buffer)
      )
    end)
  end)

  describe("#getMovements", function()
    it("returns the key sequence to move by word", function()
      local endOfWord = EndOfWord:new()

      assert.are.same(
        {
          {
            modifiers = { 'alt' },
            key = 'right'
          }
        },
        endOfWord:getMovements()
      )
    end)
  end)
end)
