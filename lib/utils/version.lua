local fnutils = require("hs.fnutils")

local versionUtils = {}

function versionUtils.hammerspoonVersionLessThan(compareVersion)
  local compare = fnutils.split(compareVersion, ".", nil, true)
  local current = fnutils.split(hs.processInfo.version, ".", nil, true)

  local maxLength = math.max(#compare, #current)

  for i = 1, maxLength do
    local compareVal = tonumber(compare[i]) or 0
    local currentVal = tonumber(current[i]) or 0

    if currentVal < compareVal then
      return true
    elseif currentVal > compareVal then
      return false
    end
  end

  return false
end

return versionUtils
