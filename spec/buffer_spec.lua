local Buffer = require('lib/buffer')
local Selection = require('lib/selection')

describe("Buffer", function()
  local text = "fdsafdsa"

  describe("#getContentsBeforeSelection()", function()
    it("returns the text in before the cursor", function()
      local buffer = Buffer:new()

      buffer:setValue(text)
      buffer:setSelectionRange(1, 0)

      assert.are.equals(
        "f",
        buffer:getContentsBeforeSelection()
      )
    end)

    it("returns nil if we're at the start", function()
      local buffer = Buffer:new()

      buffer:setValue(text)
      buffer:setSelectionRange(0, 0)

      assert.are.equals(
        nil,
        buffer:getContentsBeforeSelection()
      )
    end)
  end)

  describe("#getCurrentLineRange()", function()
    it("gets the range for line 1", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(0, 0)

      assert.are.same(
        Selection:new(0, 5),
        buffer:getCurrentLineRange()
      )
    end)

    it("gets the range for line 2", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(6, 0)

      assert.are.same(
        Selection:new(5, 10),
        buffer:getCurrentLineRange()
      )
    end)

    it("gets the range for line 3", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(15, 0)

      assert.are.same(
        Selection:new(15, 8),
        buffer:getCurrentLineRange()
      )
    end)
  end)

  describe("#getCurrentLineNumber", function()
    it("works at the start", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(0, 0) -- "(h)aha\nwhat..."

      assert.are.equals(1, buffer:getCurrentLineNumber())
    end)

    it("works in the middle of the buffer", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(6, 0) -- "haha\nw(h)at..."

      assert.are.equals(2, buffer:getCurrentLineNumber())
    end)

    it("works at the end", function()
      local buffer = Buffer:new()
      buffer:setValue("haha\nwhat yeah\nwhatever")
      buffer:setSelectionRange(22, 0) -- "haha\nwhat yeah\nwhateve(r)"

      assert.are.equals(3, buffer:getCurrentLineNumber())
    end)
  end)

  describe("#getContentsAfterSelection()", function()
    it("returns the text in front of the cursor", function()
      local buffer = Buffer:new()

      buffer:setValue(text)
      buffer:setSelectionRange(1, 0)

      assert.are.equals(
        "dsafdsa",
        buffer:getContentsAfterSelection()
      )
    end)

    it("returns nil if we're at the end", function()
      local buffer = Buffer:new()

      buffer:setValue(text)
      buffer:setSelectionRange(8, 0)

      assert.are.equals(
        nil,
        buffer:getContentsAfterSelection()
      )
    end)
  end)
end)
