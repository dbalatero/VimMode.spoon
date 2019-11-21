local Config = {}

function Config:new(options)
  options = options or {}

  -- defaults
  local config = {
    shouldDimScreenInNormalMode = true
  }

  setmetatable(config, self)
  self.__index = self

  config:setOptions(options)

  return config
end

function Config:setOptions(options)
  for key, value in pairs(options) do
    self[key] = value
  end
end

return Config
