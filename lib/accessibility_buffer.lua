local ax = require("hs._asm.axuielement")
local Buffer = dofile(vimModeScriptPath .. "lib/buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")

local AccessibilityBuffer = Buffer:new()

function AccessibilityBuffer:new()
  local buffer = Buffer:new()

  setmetatable(buffer, self)
  self.__index = self

  buffer.currentElement = nil
  buffer.value = nil
  buffer.selection = nil

  return buffer
end

function AccessibilityBuffer.getClass()
  return AccessibilityBuffer
end

function AccessibilityBuffer:getCurrentElement()
  if not self.currentElement then
    local systemElement = ax.systemWideElement()
    self.currentElement = systemElement:attributeValue("AXFocusedUIElement")
  end

  return self.currentElement
end

function AccessibilityBuffer:getSelectionRange()
  if self.selection then return self.selection end

  if not self:getCurrentElement() then return nil end

  local range = self:getCurrentElement():attributeValue("AXSelectedTextRange")
  self.selection = Selection:new(range.loc, range.len)

  return self.selection
end

function AccessibilityBuffer:setSelectionRange(location, length)
  self.selection = Selection:new(location, length)

  self:getCurrentElement():setSelectedTextRange({
    location = location,
    length = length
  })

  return self
end

function AccessibilityBuffer:getValue()
  if not self:getCurrentElement() then return nil end
  self.value = self.value or self:getCurrentElement():attributeValue("AXValue")

  return self.value
end

function AccessibilityBuffer:setValue(value)
  if not self:getCurrentElement() then return end

  self.value = value
  self:getCurrentElement():setValue(value)

  return self
end

function AccessibilityBuffer:isValid()
  if not self:getCurrentElement() then return false end
  if not self:getSelectionRange() then return false end
  if not self:isInTextField() then return false end

  return true
end

function AccessibilityBuffer.getCurrentApplication()
  return ax.applicationElement(hs.application.frontmostApplication())
end

function AccessibilityBuffer:getUIRole()
  return self:getCurrentElement():attributeValue("AXRole")
end

function AccessibilityBuffer:isInTextField()
  local role = self:getUIRole()

  return role == "AXTextField" or role == "AXTextArea"
end

function AccessibilityBuffer:enableLiveApplicationPatches()
  local axApp = self:getCurrentApplication()

  if axApp then
    -- Electron apps require this attribute to be set or else you cannot
    -- read the accessibility tree
    axApp:setAttributeValue('AXManualAccessibility', true)

    -- Chromium needs this flag to turn on accessibility in the browser
    axApp:setAttributeValue('AXEnhancedUserInterface', true)
  end
end

return AccessibilityBuffer
