local Config = require('lib/config')

describe("Config", function()
  describe("default values", function()
    it("has them", function()
      local config = Config:new()

      assert.are.same(
        {
          shouldDimScreenInNormalMode = true,
        },
        config
      )
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
