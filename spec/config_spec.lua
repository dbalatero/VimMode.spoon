local Config = require('lib/config')

describe("Config", function()
  describe("default values", function()
    it("has them", function()
      local config = Config:new()

      assert.are.same(
        {
          shouldDimScreen = true,
          disabledForApps = { 'iTerm', 'iTerm2', 'Terminal' }
        },
        config
      )
    end)
  end)

  describe("#setOptions", function()
    it("sets options", function()
      local config = Config:new()
      config:setOptions({ disabledForApps = { 'Code' } })

      assert.are.same({ 'Code' }, config.disabledForApps)
    end)
  end)
end)
