local ax = dofile(vimModeScriptPath .. "lib/axuielement.lua")

local Buffer = dofile(vimModeScriptPath .. "lib/buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local axUtils = dofile(vimModeScriptPath .. "lib/utils/ax.lua")
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

local AccessibilityBuffer = Buffer:new()

-- Some apps have a partial implementation of the OS X Accessibility API,
-- but do not actually play ball very well.
local bannedApps = {
  -- we should probably always use the fallback mode in VS Code, if someone
  -- hasn't disabled it
  Code = true,

  -- Notion's cells do not play well with advanced mode
  Notion = true,

  -- Slack always returns a selection range of:
  --   { loc = 0, len = 0 }
  --
  -- no matter where the cursor is in the text field.
  --
  -- This might be hackable in a future PR by getting clever with the AX APIs
  -- that let us get the current line's range, and selecting text to the end of
  -- the line to see where we are in the line.
  Slack = true
}

function AccessibilityBuffer:new()
  local buffer = {}

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

function AccessibilityBuffer:resetToBeginningOfLineForIndex()
  local selection = self:getCurrentLineRange()
  self:setSelectionRange(selection.location, 0)
end

function AccessibilityBuffer:getSelectionRange()
  if self.selection then return self.selection end

  if not self:getCurrentElement() then return nil end

  local range = self:getCurrentElement():attributeValue("AXSelectedTextRange")
  if not range then return nil end

  self.selection = Selection.fromRange(range)

  return self.selection
end

function AccessibilityBuffer:getCurrentLine()
  local range = self:getCurrentLineRange()
  local start = range.location + 1

  return utf8.sub(self:getValue(), start, start + range.length - 1)
end

function AccessibilityBuffer:getCurrentLineNumber()
  local number = self
    :getCurrentElement()
    :parameterizedAttributeValue(
      'AXLineForIndex',
      self:getCurrentLineRange().location
    ) or 0

  return number + 1
end

function AccessibilityBuffer:getLineCount()
  local lineNumber = self
    :getCurrentElement()
    :parameterizedAttributeValue(
      'AXLineForIndex',
      self:lastValueIndex()
    ) or 0

  return lineNumber + 1
end

function AccessibilityBuffer:setSelectionRange(location, length)
  self.selection = Selection:new(location, length)

  self:getCurrentElement():setAttributeValue("AXSelectedTextRange", {
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
  self:getCurrentElement():setAttributeValue("AXValue", value)

  return self
end

function AccessibilityBuffer:isBannedApp()
  local currentApp = hs.application.frontmostApplication()

  return not not bannedApps[currentApp:name()]
end

function AccessibilityBuffer:isValid()
  if self:isBannedApp() then return false end
  if not self:getCurrentElement() then return false end
  if not self:getSelectionRange() then return false end
  if not self:isInTextField() then return false end
  if self:isRichTextField() then return false end

  return true
end

function AccessibilityBuffer:getCurrentLineNumber()
  local axLineNumber = self:getCurrentElement():parameterizedAttributeValue(
    'AXLineForIndex',
    self:getCaretPosition()
  )

  if not axLineNumber then return 1 end

  return axLineNumber + 1
 end

function AccessibilityBuffer:getCurrentLineRange()
  return self:getRangeForLineNumber(self:getCurrentLineNumber())
end

function AccessibilityBuffer:getRangeForLineNumber(lineNumber)
  local range = self
    :getCurrentElement()
    :parameterizedAttributeValue('AXRangeForLine', lineNumber - 1)

  if not range then return Selection:new(0, 0) end

  return Selection.fromRange(range)
end

function AccessibilityBuffer:isAtLastVisibleCharacter()
  local visibleRange = self
    :getCurrentElement()
    :attributeValue("AXVisibleCharacterRange")

  if not visibleRange then return false end

  local selection = self:getSelectionRange()
  if not selection then return false end

  local lastVisibleIndex = visibleRange.length + visibleRange.location

  return lastVisibleIndex <= selection.location
end

function AccessibilityBuffer.getCurrentApplication()
  return ax.applicationElement(hs.application.frontmostApplication())
end

function AccessibilityBuffer:isInTextField()
  return axUtils.isTextField(self:getCurrentElement())
end

function AccessibilityBuffer:isRichTextField()
  return axUtils.isRichTextField(self:getCurrentElement())
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
