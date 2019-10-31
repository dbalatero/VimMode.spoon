local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local Delete = require("lib/operators/delete")

describe("Delete", function()
  describe("#getModifiedBuffer", function()
    it("deletes the range of text starting from the beginning", function()
      local buffer = Buffer:new("word one two", Selection:new(0, 0))
      local delete = Delete:new()

      local newBuffer = delete.getModifiedBuffer(buffer, 0, 4)

      assert.are.equals("one two", newBuffer.contents)
      assert.are.same(
        {
          position = 0,
          length = 0
        },
        newBuffer.selection
      )
    end)

    it("deletes the range of text in the middle", function()
      local buffer = Buffer:new("word one two", Selection:new(5, 0))
      local delete = Delete:new()

      local newBuffer = delete.getModifiedBuffer(buffer, 5, 8)

      assert.are.equals("word two", newBuffer.contents)
      assert.are.same(
        {
          position = 5,
          length = 0
        },
        newBuffer.selection
      )
    end)
  end)
end)
