local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local Word = require("lib/motions/word")

describe("Word", function()
  describe("#getMovements", function()
    it("returns the key sequence to move by word", function()
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new("cat dog mouse", selection)
      local word = Word:new()

      assert.are.same(
        {
          {
            modifiers = { 'alt' },
            character = 'right'
          }
        },
        word:getMovements(buffer)
      )
    end)

    it("returns nil if you are at the end of a line", function()
      local selection = Selection:new(3, 0)
      local buffer = Buffer:new("cat\ndog", selection)
      local word = Word:new()

      assert.are.equals(nil, word:getMovements(buffer))
    end)

    it("returns nil if you are at the end of a string", function()
      local selection = Selection:new(3, 0)
      local buffer = Buffer:new("cat", selection)
      local word = Word:new()

      assert.are.equals(nil, word:getMovements(buffer))
    end)
  end)
end)
