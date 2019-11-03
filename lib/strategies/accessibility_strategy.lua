local ax = require("hs._asm.axuielement")
local AccessibilityBuffer = dofile(vimModeScriptPath .. "lib/accessibility_buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")

local AccessibilityStrategy = {}

function AccessibilityStrategy:new(vim)
  local strategy = {
    currentElement = nil,
    vim = vim
  }

  setmetatable(strategy, self)
  self.__index = self

  strategy:enableLiveApplicationPatches()

  return strategy
end

function AccessibilityStrategy:fire()
  self:getNextBuffer()
end

function AccessibilityStrategy:getNextBuffer()
  local operator = self.vim.commandState.operator
  local motion = self.vim.commandState.motion

  local buffer = AccessibilityBuffer:new()
  local range = motion:getRange(buffer)

  local start = range.start
  local finish = range.finish

  if operator then
    if range.mode == 'exclusive' then finish = finish - 1 end

    return operator.getModifiedBuffer(buffer, start, finish)
  else
    local direction = 'right'

    if start < buffer:getSelectionRange().location then
      direction = 'left'
    end

    local location = (direction == 'left' and start) or finish

    return AccessibilityBuffer:new():setSelectionRange(location, 0)
  end
end

function AccessibilityStrategy:getCurrentElement()
  if not self.currentElement then
    local systemElement = ax.systemWideElement()
    self.currentElement = systemElement:attributeValue("AXFocusedUIElement")
  end

  return self.currentElement
end

function AccessibilityStrategy:getSelection()
  if not self:getCurrentElement() then return nil end

  local range = self:getCurrentElement():attributeValue("AXSelectedTextRange")

  return Selection:new(range.loc, range.length)
end

function AccessibilityStrategy:setSelectionRange(selection)
  self:getCurrentElement():setSelectedTextRange(selection)
end

function AccessibilityStrategy:getValue()
  if not self:getCurrentElement() then return nil end
  return self:getCurrentElement():attributeValue("AXValue")
end

function AccessibilityStrategy:setValue(value)
  if not self:getCurrentElement() then return end
  self:getCurrentElement().setValue(value)
end

function AccessibilityStrategy:isValid()
  if not self:getCurrentElement() then return false end
  if not self:getSelection() then return false end
  if not self:isInTextField() then return false end

  return true
end

function AccessibilityStrategy.getCurrentApplication()
  return ax.applicationElement(hs.application.frontmostApplication())
end

function AccessibilityStrategy:getUIRole()
  return self:getCurrentElement():attributeValue("AXRole")
end

function AccessibilityStrategy:isInTextField()
  local role = self:getUIRole()

  return role == "AXTextField" or role == "AXTextArea"
end

function AccessibilityStrategy:enableLiveApplicationPatches()
  local axApp = self:getCurrentApplication()

  if axApp then
    -- Electron apps require this attribute to be set or else you cannot
    -- read the accessibility tree
    axApp:setAttributeValue('AXManualAccessibility', true)

    -- Chromium needs this flag to turn on accessibility in the browser
    axApp:setAttributeValue('AXEnhancedUserInterface', true)
  end
end

return AccessibilityStrategy
