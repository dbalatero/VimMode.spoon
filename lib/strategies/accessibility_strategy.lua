local ax = require("hs._asm.axuielement")
local inspect = hs.inspect.inspect

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

  return strategy
end

function AccessibilityStrategy:fire()
  local operator = self.vim.commandState.operator
  local motion = self.vim.commandState.motion
  local buffer = AccessibilityBuffer:new()

  if operator then vimLogger.i("Firing operator = ", operator.name) end
  if motion then vimLogger.i("Firing motion = ", motion.name) end

  -- set the caret position if we are in visual mode
  if self.vim:isMode('visual') then
    vimLogger.i('setting caret = ' .. inspect(self.vim.visualCaretPosition))
    buffer:setCaretPosition(self.vim.visualCaretPosition)
  end

  local range = motion:getRange(buffer, operator)

  -- just cancel if the motion decides there isn't anything
  -- to operate on (end of buffer, etc)
  if not range then return nil end

  local start = range.start
  local finish = range.finish

  if operator then
    if range.mode == 'exclusive' then finish = finish - 1 end

    if finish + 1 >= buffer:getLength() then
      finish = buffer:getLength() - 1
    end

    local length = finish - start + 1

    self:setSelection(start, length)
    operator:modifySelection(buffer, start, finish)

    hs.timer.doAfter(100 / 1000, function()
      if range.direction == 'linewise' then
        local newBuffer = AccessibilityBuffer
          :new()
          :setSelectionRange(start, 0)

        -- reset the cursor to the beginning of the line
        newBuffer:resetToBeginningOfLineForIndex()
      end
    end)
  else
    local currentRange = buffer:getSelectionRange()

    local location
    local length = 0

    if self.vim:isMode('visual') then
      vimLogger.i("Handling visual mode")

      local currentCharRange = currentRange:getCharRange()
      local caretPosition = buffer:getCaretPosition()

      vimLogger.i("currentCharRange = " .. inspect(currentCharRange))
      vimLogger.i("motionRange = " .. inspect(range))
      vimLogger.i("caretPosition = " .. inspect(caretPosition))

      local result = visualUtils.getNewRange(
        currentCharRange,
        range,
        caretPosition
      )

      vimLogger.i("result = " .. inspect(result))

      local newRange = result.range

      local finish = newRange.finish
      if range.mode == 'exclusive' then finish = finish - 1 end

      location = newRange.start
      length = newRange.finish - newRange.start + 1

      -- update the caret position
      self.vim.visualCaretPosition = result.caretPosition
    else
      local direction = 'right'

      if start < currentRange:positionEnd() then
        direction = 'left'
      end

      location = (direction == 'left' and start) or finish
    end

    AccessibilityBuffer:new():setSelectionRange(location, length)
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

  return Selection:new(range.loc, range.len)
end

function AccessibilityStrategy:setSelection(location, length)
  return self:setSelectionRange(Selection:new(location, length))
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
  return AccessibilityBuffer:new():isValid()
end

function AccessibilityStrategy:getUIRole()
  return self:getCurrentElement():attributeValue("AXRole")
end

function AccessibilityStrategy:isInTextField()
  local role = self:getUIRole()

  return role == "AXTextField" or role == "AXTextArea"
end

return AccessibilityStrategy
