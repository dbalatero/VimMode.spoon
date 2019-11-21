local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local Delete = require("lib/operators/delete")

describe("Delete", function()
  it("has a name", function()
    assert.are.equals("delete", Delete:new().name)
  end)

  describe("#getModifiedBuffer", function()
    it("deletes the range of text starting from the beginning", function()
      local buffer = Buffer:new()
      buffer:setValue("word one two")
      buffer:setSelectionRange(0, 0)

      local delete = Delete:new()

      local newBuffer = delete:getModifiedBuffer(buffer, 0, 4)

      assert.are.equals("one two", newBuffer:getValue())
      assert.are.same(
        Selection:new(0, 0),
        newBuffer:getSelectionRange()
      )
    end)

    it("deletes the range of text in the middle", function()
      local buffer = Buffer:new()
      buffer:setValue("word one two")
      buffer:setSelectionRange(5, 0)

      local delete = Delete:new()

      local newBuffer = delete:getModifiedBuffer(buffer, 5, 8)

      assert.are.equals("word two", newBuffer:getValue())
      assert.are.same(
        Selection:new(5, 0),
        newBuffer:getSelectionRange()
      )
    end)
  end)
end)
