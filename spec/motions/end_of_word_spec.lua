local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local EndOfWord = require("lib/motions/end_of_word")

describe("EndOfWord", function()
  it("has a name", function()
    assert.are.equals("end_of_word", EndOfWord:new().name)
  end)

  describe("#getRange", function()
    it("handles simple words", function()
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new("cat dog mouse", selection)
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
      local selection = Selection:new(2, 0)
      local buffer = Buffer:new("cat dog mouse", selection)
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
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new("cat\ndog", selection)
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
