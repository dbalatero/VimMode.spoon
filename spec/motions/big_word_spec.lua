local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local BigWord = require("lib/motions/big_word")

describe("BigWord", function()
  it("has a name", function()
    assert.are.equals("big_word", BigWord:new().name)
  end)

  describe("#getRange", function()
    it("handles simple words", function()
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new("cat dog mouse", selection)
      local bigWord = BigWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 4,
          mode = "exclusive",
          direction = "characterwise"
        },
        bigWord:getRange(buffer)
      )
    end)

    it("handles punctuation boundaries", function()
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new("www.site.com ok", selection)
      local bigWord = BigWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 13,
          mode = "exclusive",
          direction = "characterwise"
        },
        bigWord:getRange(buffer)
      )
    end)
  end)

  describe("#getMovements", function()
    it("returns the key sequence to move by word", function()
      local bigWord = BigWord:new()

      assert.are.same(
        {
          {
            modifiers = { 'alt' },
            key = 'right'
          }
        },
        bigWord:getMovements()
      )
    end)
  end)
end)
