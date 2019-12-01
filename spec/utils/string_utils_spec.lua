local stringUtils = require("lib/utils/string_utils")

describe("stringUtils", function()
  describe("#findPrevIndex", function()
    it("should find the prev occurrence of a character", function()
      local str = "12345"
      local index = stringUtils.findPrevIndex(str, "2", 5)

      assert.are.equals(2, index)
    end)

    it("should return nil if it doesn't find it", function()
      local str = "12345"
      local index = stringUtils.findPrevIndex(str, "a")

      assert.are.equals(nil, index)
    end)
  end)

  describe("#findNextIndex", function()
    it("should find the next occurrence of a character", function()
      local str = "12345"
      local index = stringUtils.findNextIndex(str, "5")

      assert.are.equals(5, index)
    end)

    it("should return nil if it doesn't find it", function()
      local str = "12345"
      local index = stringUtils.findNextIndex(str, "6")

      assert.are.equals(nil, index)
    end)
  end)
end)
