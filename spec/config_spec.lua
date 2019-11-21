local Config = require('lib/config')

describe("Config", function()
  describe("default values", function()
    it("has them", function()
      local config = Config:new()

      assert.are.equals(true, config.shouldShowAlertInNormalMode)
      assert.are.equals("Courier New", config.alert.font)
    end)
  end)

  describe("#setOptions", function()
    it("sets options", function()
      local config = Config:new()
      config:setOptions({ shouldDimScreenInNormalMode = false })

      assert.are.same(false, config.shouldDimScreenInNormalMode)
    end)
  end)
end)
