local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local LineEnd = require("lib/motions/line_end")

describe("LineEnd", function()
  it("has a name", function()
    assert.are.equals("line_end", LineEnd:new().name)
  end)

  describe("#getRange", function()
    it("handles simple line deletes", function()
      local buffer = Buffer:new()
      buffer:setValue("ab\ncd")
      buffer:setSelectionRange(0, 0) -- cat (d)og mouse

      local lineEnd = LineEnd:new()

      assert.are.same(
        {
          start = 0,
          finish = 2,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineEnd:getRange(buffer)
      )
    end)

    it("handles first lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(4, 0) -- cat (d)og mouse

      local lineEnd = LineEnd:new()

      assert.are.same(
        {
          start = 4,
          finish = 13,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineEnd:getRange(buffer)
      )
    end)

    it("handles 2 lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat\ndog mouse")
      buffer:setSelectionRange(6, 0) -- cat\ndo(g) mouse

      local lineEnd = LineEnd:new()

      assert.are.same(
        {
          start = 6,
          finish = 13,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineEnd:getRange(buffer)
      )
    end)

    it("handles 3 lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat\ndog\nmouse")
      buffer:setSelectionRange(10, 0) -- cat\ndog\nmo(u)se

      local lineEnd = LineEnd:new()

      assert.are.same(
        {
          start = 10,
          finish = 13,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineEnd:getRange(buffer)
      )
    end)
  end)
end)
