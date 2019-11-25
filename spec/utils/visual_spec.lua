local visualUtils = require("lib/utils/visual")

local getNewRange = visualUtils.getNewRange

describe("visual utils", function()
  describe("#getNewRange", function()
    it("can handle going to the left from a left cursor position", function()
      local currentRange = { start = 3, finish = 8 }
      local motionRange = { start = 0, finish = 3 }
      local caretPosition = 3

      assert.are.same(
        {
          caretPosition = 0,
          range = { start = 0, finish = 8 }
        },
        getNewRange(currentRange, motionRange, caretPosition, "pause")
      )
    end)

    it("can handle going to the right from a left cursor position", function()
      local currentRange = { start = 0, finish = 5 }
      local motionRange = { start = 0, finish = 1 }
      local caretPosition = 0

      assert.are.same(
        {
          caretPosition = 1,
          range = { start = 1, finish = 5 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can handle going to the left from a right cursor position", function()
      local currentRange = { start = 0, finish = 5 }
      local motionRange = { start = 3, finish = 5 }
      local caretPosition = 5

      assert.are.same(
        {
          caretPosition = 3,
          range = { start = 0, finish = 3 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can handle going to the right from a right cursor position", function()
      local currentRange = { start = 0, finish = 5 }
      local motionRange = { start = 5, finish = 8 }
      local caretPosition = 5

      assert.are.same(
        {
          caretPosition = 8,
          range = { start = 0, finish = 8 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can handle the start of the buffer", function()
      local currentRange = { start = 0, finish = 0 }
      local motionRange = { start = 0, finish = 5 }
      local caretPosition = 0

      assert.are.same(
        {
          caretPosition = 5,
          range = { start = 0, finish = 5 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can handle the end of the buffer", function()
      local currentRange = { start = 33, finish = 33 }
      local motionRange = { start = 16, finish = 33 }
      local caretPosition = 33

      assert.are.same(
        {
          caretPosition = 16,
          range = { start = 16, finish = 33 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can handle a beginning of line movement", function()
      local currentRange = { start = 16, finish = 33 }
      local motionRange = { start = 0, finish = 33 }
      local caretPosition = 16

      assert.are.same(
        {
          caretPosition = 0,
          range = { start = 0, finish = 33 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)

    it("can cancel out a linewise movement", function()
      local currentRange = { start = 28, finish = 62 }
      local motionRange = { start = 28, finish = 62 }
      local caretPosition = 28

      assert.are.same(
        {
          caretPosition = 62,
          range = { start = 62, finish = 62 }
        },
        getNewRange(currentRange, motionRange, caretPosition)
      )
    end)
  end)
end)
