local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local Word = require("lib/motions/word")

describe("Word", function()
  describe("#getMovements", function()
    local selection = Selection:new(0, 0)
    local buffer = Buffer:new("cat dog mouse", selection)
    local word

    before_each(function()
      word = Word:new()
    end)

    it("returns the key sequence to move by word", function()
      assert.are.same(
        {
          {
            modifiers = { 'alt' },
            character = 'right'
          }
        },
        word:getMovements()
      )
    end)
  end)
end)
