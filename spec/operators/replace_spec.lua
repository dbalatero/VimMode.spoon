local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local Replace = require("lib/operators/replace")

describe("Replace", function()
  it("has a name", function()
    assert.are.equals("replace", Replace:new().name)
  end)

  describe("#getModifiedBuffer", function()
    it("deletes the range of text starting from the beginning", function()
      local buffer = Buffer:new()
      buffer:setValue("abc")
      buffer:setSelectionRange(0, 0)

      local replace = Replace:new()
      replace:setExtraChar("1")

      local newBuffer = replace:getModifiedBuffer(buffer, 0, 0)

      assert.are.equals("1bc", newBuffer:getValue())
      assert.are.same(
        Selection:new(0, 0),
        newBuffer:getSelectionRange()
      )
    end)

    it("replaces the range in the middle", function()
      local buffer = Buffer:new()
      buffer:setValue("abc")
      buffer:setSelectionRange(1, 0)

      local replace = Replace:new()
      replace:setExtraChar("d")

      local newBuffer = replace:getModifiedBuffer(buffer, 1, 1)

      assert.are.equals("adc", newBuffer:getValue())
      assert.are.same(
        Selection:new(1, 0),
        newBuffer:getSelectionRange()
      )
    end)

    it("replaces with multiple chars if it's a range > 1", function()
      local buffer = Buffer:new()
      buffer:setValue("abc def")
      buffer:setSelectionRange(0, 0)

      local replace = Replace:new()
      replace:setExtraChar("*")

      local newBuffer = replace:getModifiedBuffer(buffer, 0, 2)

      assert.are.equals("*** def", newBuffer:getValue())
      assert.are.same(
        Selection:new(0, 0),
        newBuffer:getSelectionRange()
      )
    end)
  end)
end)
