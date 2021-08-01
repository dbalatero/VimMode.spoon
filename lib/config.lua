local Config = {}

function Config:new(options)
  options = options or {}

  -- defaults
  local config = {
    alert = {
      font = "Courier New"
    },
    betaFeatures = {},
    fallbackOnlyApps = {},
    fallbackOnlyUrlPatterns = {},
    shouldShowAlertInNormalMode = true,
    shouldDimScreenInNormalMode = true,
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

function Config:isBetaFeatureEnabled(feature)
  return not not self.betaFeatures[feature]
end

function Config:enableBetaFeature(feature)
  self.betaFeatures[feature] = true
end

function Config:disableBetaFeature(feature)
  self.betaFeatures[feature] = false
end

return Config
