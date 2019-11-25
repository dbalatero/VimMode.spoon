local ax = require("hs._asm.axuielement")
local Strategy = dofile(vimModeScriptPath .. "lib/strategy.lua")
local AccessibilityBuffer = dofile(vimModeScriptPath .. "lib/accessibility_buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local visualUtils = dofile(vimModeScriptPath .. "lib/utils/visual.lua")

local AccessibilityStrategy = Strategy:new()

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

  -- just cancel if the motion doesn't decide to do anything
  if not range then return nil end

  local start = range.start
  local finish = range.finish

  if operator then
    if range.mode == 'exclusive' then finish = finish - 1 end

    local newBuffer = operator:getModifiedBuffer(buffer, start, finish)

    if range.direction == 'linewise' then
      -- reset the cursor to the beginning of the line
      newBuffer:resetToBeginningOfLineForIndex()
    end

    return newBuffer
  else
    local currentRange = buffer:getSelectionRange()

    local location
    local length = 0

    if self.vim:isMode('visual') then
      vimLogger.i("Handling visual mode")

      if not self.vim.visualCaretPosition then
        self.vim.visualCaretPosition = currentRange:positionEnd()
      end

      local currentCharRange = currentRange:getCharRange()

      vimLogger.i("currentCharRange = " .. inspect(currentCharRange))
      vimLogger.i("motionRange = " .. inspect(range))
      vimLogger.i("caretPosition = " .. inspect(self.vim.visualCaretPosition))

      local result = visualUtils.getNewRange(
        currentCharRange,
        range,
        self.vim.visualCaretPosition
      )

      vimLogger.i("result = " .. inspect(result))

      local newRange = result.range

      location = newRange.start
      length = newRange.finish - newRange.start

      -- update the caret position
      self.vim.visualCaretPosition = result.caretPosition
    else
      local direction = 'right'

      if start < currentRange:positionEnd() then
        direction = 'left'
      end

      location = (direction == 'left' and start) or finish
    end

    return AccessibilityBuffer:new():setSelectionRange(location, length)
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

  if not range then return nil end

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
