local Buffer = require("lib/buffer")
local BackWord = require("lib/motions/back_word")

describe("BackWord", function()
  it("has a name", function()
    assert.are.equals("back_word", BackWord:new().name)
  end)

  describe("#getRange", function()
    it("handles simple words", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(3, 0)

      local backWord = BackWord:new()

      assert.are.same(
        {
          start = 0,
          finish = 3,
          mode = "exclusive",
          direction = "characterwise"
        },
        backWord:getRange(buffer)
      )
    end)

    it("handles starting on the next word", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse") -- cat dog (m)ouse
      buffer:setSelectionRange(8, 0)

      local backWord = BackWord:new()
      local result = backWord:getRange(buffer)

      assert.are.same(
        {
          start = 4, -- cat (d)og mouse
          finish = 8,
          mode = "exclusive",
          direction = "characterwise"
        },
        result
      )
    end)

    it("crosses the new line boundary", function()
      local buffer = Buffer:new()
      buffer:setValue("ab cd\n  ef")
      buffer:setSelectionRange(8, 0) -- (e)f

      local backWord = BackWord:new()

      assert.are.same(
        {
          start = 3,
          finish = 8,
          mode = "exclusive",
          direction = "characterwise"
        },
        backWord:getRange(buffer)
      )
    end)

    it("handles punctuation stops", function()
      local buffer = Buffer:new()
      buffer:setValue("www.test.com")
      buffer:setSelectionRange(11, 0) -- .co(m)

      local backWord = BackWord:new()

      assert.are.same(
        {
          start = 9,
          finish = 11,
          mode = "exclusive",
          direction = "characterwise"
        },
        backWord:getRange(buffer)
      )
    end)

    it("handles jumping across punctuation sequences", function()
      local buffer = Buffer:new()
      buffer:setValue("www.test..com")
      buffer:setSelectionRange(10, 0) -- ..(c)om

      local backWord = BackWord:new()

      assert.are.same(
        {
          start = 8,
          finish = 10,
          mode = "exclusive",
          direction = "characterwise"
        },
        backWord:getRange(buffer)
      )
    end)

    it("handles jumping from punctuation thru words", function()
      local buffer = Buffer:new()
      buffer:setValue("www.test.com")
      buffer:setSelectionRange(8, 0) -- www.test(.)com

      local backWord = BackWord:new()

      assert.are.same(
        {
          start = 4,
          finish = 8,
          mode = "exclusive",
          direction = "characterwise"
        },
        backWord:getRange(buffer)
      )
    end)
  end)
end)
