local ax = require("hs._asm.axuielement")

local axUtils = {}

axUtils.isTextField = function(element)
  if not element then return false end

  local role = element:attributeValue("AXRole")

  return role == "AXTextField" or role == "AXTextArea"
end

axUtils.isRichTextField = function(element)
  -- If the current element has any children typically it means there
  -- are fancy-ass things in the input element like images, complex HTML,
  -- etc.
  --
  -- from observation, plain text inputs/textareas do not seem to have
  -- children.
  if not element then return false end

  local children = element:attributeValue("AXChildren")

  if not children then return false end

  return #children > 0
end

-------------------------------------------------
-- patching Accessibility APIs on a per-app basis
-------------------------------------------------
local function patchChromiumWithAccessibilityFlag(axApp)
  -- Google Chrome needs this flag to turn on accessibility in the browser
  axApp:setAttributeValue('AXEnhancedUserInterface', true)
end

local function patchElectronAppsWithAccessibilityFlag(axApp)
  -- Electron apps require this attribute to be set or else you cannot
  -- read the accessibility tree
  axApp:setAttributeValue('AXManualAccessibility', true)
end

local alreadyPatchedApps = {}

axUtils.patchCurrentApplication = function()
  local currentApp = hs.application.frontmostApplication()

  -- cache whether we patched it already by app name and pid
  -- pray for no collisions hahahahahhahaha
  local patchKey = currentApp:name() .. currentApp:pid()
  if alreadyPatchedApps[patchKey] then return end

  alreadyPatchedApps[patchKey] = true
  local axApp = ax.applicationElement(currentApp)

  if axApp then
    patchChromiumWithAccessibilityFlag(axApp)
    patchElectronAppsWithAccessibilityFlag(axApp)
  end
end

return axUtils
