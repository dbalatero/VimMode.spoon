local ax = require("hs._asm.axuielement")

local Buffer = dofile(vimModeScriptPath .. "lib/buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")

local Word = dofile(vimModeScriptPath .. "lib/motions/word.lua")
local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")

local Vim = {}

vimLogger = hs.logger.new('vim', 'debug')

function Vim:new()
  local vim = {
    commandState = CommandState:new()
  }

  setmetatable(vim, self)
  self.__index = self

  return vim
end

function Vim:getBuffer()
  -- for now force manual accessibility on
  local axApp = ax.applicationElement(hs.application.frontmostApplication())
  axApp:setAttributeValue('AXManualAccessibility', true)
  axApp:setAttributeValue('AXEnhancedUserInterface', true)

  local systemElement = ax.systemWideElement()
  local currentElement = systemElement:attributeValue("AXFocusedUIElement")
  local role = currentElement:attributeValue("AXRole")

  if role == "AXTextField" or role == "AXTextArea" then
    local text = currentElement:attributeValue("AXValue")
    local textLength = currentElement:attributeValue("AXNumberOfCharacters")
    local range = currentElement:attributeValue("AXSelectedTextRange")

    return Buffer:new(text, Selection:new(range.loc, range.len))
  else
    return nil
  end
end

function Vim.currentElementSupportsAccessibility()
  local systemElement = ax.systemWideElement()
  local currentElement = systemElement:attributeValue("AXFocusedUIElement")

  if not currentElement then return false end

  local range = currentElement:attributeValue("AXSelectedTextRange")

  if not range then return false end

  return true
end

function getCurrentElement()
  local systemElement = ax.systemWideElement()
  return systemElement:attributeValue("AXFocusedUIElement")
end

function setValue(value)
  getCurrentElement().setValue(value)
end

function selectTextRange(start, finish)
  getCurrentElement():setSelectedTextRange({
    location = start,
    length = finish - start
  })
end

function Vim:spikeWordDelete()
  if self:currentElementSupportsAccessibility() then
    local buffer = self:getBuffer()
    local operator = Delete:new()
    local motion = Word:new()
    local range = motion:getRange(buffer)

    local finish = range.finish
    if range.mode == 'exclusive' then finish = finish - 1 end

    local newBuffer = operator.getModifiedBuffer(
      buffer,
      range.start,
      finish
    )

    -- update value and cursor
    getCurrentElement():setValue(newBuffer.contents)
    getCurrentElement():setSelectedTextRange({
      location = newBuffer.selection.position,
      length = newBuffer.selection.length
    })
  end
end

return Vim
