local Buffer = require("lib/buffer")
local Selection = require("lib/selection")
local LineBeginning = require("lib/motions/line_beginning")

describe("LineBeginning", function()
  it("has a name", function()
    assert.are.equals("line_beginning", LineBeginning:new().name)
  end)

  describe("#getRange", function()
    it("handles first lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat dog mouse")
      buffer:setSelectionRange(4, 0) -- cat (d)og mouse

      local lineBeginning = LineBeginning:new()

      assert.are.same(
        {
          start = 0,
          finish = 4,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineBeginning:getRange(buffer)
      )
    end)

    it("handles 2 lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat\ndog mouse")
      buffer:setSelectionRange(6, 0) -- cat\ndo(g) mouse

      local lineBeginning = LineBeginning:new()

      assert.are.same(
        {
          start = 4,
          finish = 6,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineBeginning:getRange(buffer)
      )
    end)

    it("handles 3 lines", function()
      local buffer = Buffer:new()
      buffer:setValue("cat\ndog\nmouse")
      buffer:setSelectionRange(10, 0) -- cat\ndog\nmo(u)se

      local lineBeginning = LineBeginning:new()

      assert.are.same(
        {
          start = 8,
          finish = 10,
          mode = "exclusive",
          direction = "characterwise"
        },
        lineBeginning:getRange(buffer)
      )
    end)
  end)
end)
