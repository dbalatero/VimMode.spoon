local numberUtils = require("lib/utils/number_utils")

describe("numberUtils", function()
  describe("#pushDigit", function()
    local pushDigit = numberUtils.pushDigit

    it("concats a digit onto 0", function()
      assert.are.equals(1, pushDigit(0, 1))
    end)

    it("does nothing when pushing 0 onto 0", function()
      assert.are.equals(0, pushDigit(0, 0))
    end)

    it("pushes a digit onto another", function()
      assert.are.equals(10, pushDigit(1, 0))
      assert.are.equals(21, pushDigit(2, 1))
      assert.are.equals(105, pushDigit(10, 5))
      assert.are.equals(1239, pushDigit(123, 9))
    end)
  end)
end)
