local Buffer = require('lib/buffer')
local Selection = require('lib/selection')

describe("Buffer", function()
  local text = "fdsafdsa"

  describe("#getContentsBeforeSelection()", function()
    it("returns the text in before the cursor", function()
      local selection = Selection:new(1, 0)
      local buffer = Buffer:new(text, selection)

      assert.are.equals(
        "f",
        buffer:getContentsBeforeSelection()
      )
    end)

    it("returns nil if we're at the start", function()
      local selection = Selection:new(0, 0)
      local buffer = Buffer:new(text, selection)

      assert.are.equals(
        nil,
        buffer:getContentsBeforeSelection()
      )
    end)
  end)

  describe("#getContentsAfterSelection()", function()
    it("returns the text in front of the cursor", function()
      local selection = Selection:new(1, 0)
      local buffer = Buffer:new(text, selection)

      assert.are.equals(
        "dsafdsa",
        buffer:getContentsAfterSelection()
      )
    end)

    it("returns nil if we're at the end", function()
      local selection = Selection:new(8, 0)
      local buffer = Buffer:new(text, selection)

      assert.are.equals(
        nil,
        buffer:getContentsAfterSelection()
      )
    end)
  end)

  describe("#nextChar", function()
    it("returns the next char after the cursor", function()
      local selection = Selection:new(1, 0)
      local buffer = Buffer:new(text, selection)

      assert.are.equals(
        "d",
        buffer:nextChar()
      )
    end)
  end)
end)
