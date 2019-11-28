local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local BigWord = require("lib/motions/big_word")

describe("BigWord", function()
  it("has a name", function()
    assert.are.equals("big_word", BigWord:new().name)
  end)

  describe("#getRange", function()
    it("handles simple words", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(0, 0)

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
      local buffer = Buffer:new()
      buffer:setValue("www.site.com ok")
      buffer:setSelectionRange(0, 0)

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
            key = 'right',
            selection = true
          }
        },
        bigWord:getMovements()
      )
    end)
  end)
end)
