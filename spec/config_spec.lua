local Config = require('lib/config')

describe("Config", function()
  describe("default values", function()
    it("has them", function()
      local config = Config:new()

      assert.are.same(
        {
          shouldDimScreen = true,
        },
        config
      )
    end)
  end)

  describe("#setOptions", function()
    it("sets options", function()
      local config = Config:new()
      config:setOptions({ shouldDimScreen = false })

      assert.are.same(false, config.shouldDimScreen)
    end)
  end)
end)
