local ax = require("hs._asm.axuielement")

local Buffer = dofile(vimModeScriptPath .. "lib/buffer.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")

local Word = dofile(vimModeScriptPath .. "lib/motions/word.lua")
local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")
local createStateMachine = dofile(vimModeScriptPath .. "lib/state.lua")

local Vim = {}

vimLogger = hs.logger.new('vim', 'debug')

function Vim:new()
  local vim = {}

  setmetatable(vim, self)
  self.__index = self

  vim:resetCommandState()

  vim.mode = 'insert'
  vim.state = createStateMachine(vim)

  vim.modals = {
    normal = vim:buildNormalModeModal()
  }

  return vim
end

function Vim:resetCommandState()
  self.commandState = CommandState:new()
end

function Vim:buildNormalModeModal()
  local modal = hs.hotkey.modal.new()

  modal:bind({}, 'i', function() self:exit() end)

  modal:bind({}, 'd', function()
    self.state:enterOperator(Delete:new())
  end)

  modal:bind({}, 'w', function()
    vimLogger.i("firing w")
    self.state:enterMotion(Word:new())
  end)

  return modal
end

function Vim:exit()
  vimLogger.i("Exiting Vim")
  self.state:enterInsert()
end

function Vim:setInsertMode()
  self.mode = "insert"
end

function Vim:setNormalMode()
  self.mode = "normal"
end

function Vim:enter()
  vimLogger.i("Entering Vim")
  self.state:enterNormal()
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

function Vim:fireCommandState()
  local operator = self.commandState.operator
  local motion = self.commandState.motion

  if self:currentElementSupportsAccessibility() then
    local buffer = self:getBuffer()
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
  else
    -- select the movement
    for _, movement in ipairs(motion.getMovements()) do
      hs.eventtap.keyStroke(
        { "shift", table.unpack(movement.modifiers) },
        movement.key,
        0
      )
    end

    -- fire the operator
    for _, movement in pairs(operator.getKeys()) do
      hs.eventtap.keyStroke(movement.modifiers, movement.key, 0)
    end
  end
end

return Vim
