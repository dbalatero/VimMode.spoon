local ax = require("hs._asm.axuielement")

dofile(vimModeScriptPath .. "lib/utils/benchmark.lua")

local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")
local AccessibilityStrategy = dofile(vimModeScriptPath .. "lib/strategies/accessibility_strategy.lua")
local KeyboardStrategy = dofile(vimModeScriptPath .. "lib/strategies/keyboard_strategy.lua")

local BackWord = dofile(vimModeScriptPath .. "lib/motions/back_word.lua")
local BigWord = dofile(vimModeScriptPath .. "lib/motions/big_word.lua")
local EndOfWord = dofile(vimModeScriptPath .. "lib/motions/end_of_word.lua")
local LineBeginning = dofile(vimModeScriptPath .. "lib/motions/line_beginning.lua")
local LineEnd = dofile(vimModeScriptPath .. "lib/motions/line_end.lua")
local Word = dofile(vimModeScriptPath .. "lib/motions/word.lua")

local Left = dofile(vimModeScriptPath .. "lib/motions/left.lua")
local Right = dofile(vimModeScriptPath .. "lib/motions/right.lua")

local Change = dofile(vimModeScriptPath .. "lib/operators/change.lua")
local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")
local Yank = dofile(vimModeScriptPath .. "lib/operators/yank.lua")

local createStateMachine = dofile(vimModeScriptPath .. "lib/state.lua")

local Vim = {}

vimLogger = hs.logger.new('vim', 'debug')

local function createVimModal()
  local modal = hs.hotkey.modal.new()

  modal.bindWithRepeat = function(mdl, mods, key, fn)
    local message = nil

    return mdl:bind(mods, key, message, fn, fn, fn)
  end

  return modal
end

function Vim:new()
  local vim = {}

  setmetatable(vim, self)
  self.__index = self

  vim:resetCommandState()

  vim.mode = 'insert'
  vim.state = createStateMachine(vim)

  vim.modals = {
    normal = vim:buildNormalModeModal(),
    operatorPending = vim:buildOperatorPendingModal()
  }

  return vim
end

function Vim:resetCommandState()
  self.commandState = CommandState:new()
end

function Vim:operator(type)
  return function()
    self.state:enterOperator(type:new())
  end
end


function Vim:motion(type)
  return function()
    self.state:enterMotion(type:new())
  end
end

function Vim:bindMotionsToModal(modal)
  return modal
    :bindWithRepeat({}, '0', self:motion(LineBeginning))
    :bindWithRepeat({'shift'}, '4', self:motion(LineEnd)) -- $
    :bindWithRepeat({}, 'b', self:motion(BackWord))
    :bindWithRepeat({}, 'e', self:motion(EndOfWord))
    :bindWithRepeat({}, 'h', self:motion(Left))
    :bindWithRepeat({}, 'l', self:motion(Right))
    :bindWithRepeat({}, 'w', self:motion(Word))
    :bindWithRepeat({'shift'}, 'w', self:motion(BigWord))
end

function Vim:buildOperatorPendingModal()
  local modal = self:bindMotionsToModal(createVimModal())

  return modal
end

function Vim:buildNormalModeModal()
  local modal = self:bindMotionsToModal(createVimModal())

  return modal
    :bind({}, 'i', function() self:exit() end)
    :bind({}, 'c', nil, self:operator(Change))
    :bind({}, 'd', nil, self:operator(Delete))
    :bind({}, 'y', nil, self:operator(Yank))
    :bind({}, '/', function()
      hs.eventtap.keyStroke({'cmd'}, 'f', 0)
      self:exit()
    end)
    :bind({}, 'p', function()
      hs.eventtap.keyStroke({'cmd'}, 'v', 0)
    end)
    :bind({}, 'o', function()
      self:exit()
      hs.eventtap.keyStroke({'cmd'}, 'right', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
    end)
    :bind({}, 'u', function()
      -- undo
      hs.eventtap.keyStroke({'cmd'}, 'z', 0)
    end)
    :bind({'ctrl'}, 'r', function()
      -- redo
      hs.eventtap.keyStroke({'cmd','shift'}, 'z', 0)
    end)
    :bind({'shift'}, 'o', function()
      self:exit()
      hs.eventtap.keyStroke({'cmd'}, 'left', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
      hs.eventtap.keyStroke({}, 'up', 0)
    end)
    :bind({'shift'}, 'a', function()
      self:motion(LineEnd)()
      self:exit()
    end)
    :bind({'shift'}, 'c', function()
      self:operator(Change)()
      self:motion(LineEnd)()
    end)
    :bind({'shift'}, 'd', function()
      self:operator(Delete)()
      self:motion(LineEnd)()
    end)
    :bindWithRepeat({}, 'x', function()
      self:operator(Delete)()
      self:motion(Right)()
    end)
end

function Vim:exit()
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

function Vim:exitAllModals()
  for _, modal in pairs(self.modals) do
    modal:exit()
  end
end

function Vim:enterModal(name)
  vimLogger.i("Entering modal " .. name)
  self:exitAllModals()
  self.modals[name]:enter()
end

function findFirst(list, fn)
  for _, item in ipairs(list) do
    if fn(item) then return item end
  end

  return nil
end

function Vim:fireCommandState()
  local operator = self.commandState.operator
  local motion = self.commandState.motion

  local strategies = {
    AccessibilityStrategy:new(self),
    KeyboardStrategy:new(self)
  }

  local strategy = findFirst(strategies, function(strategy)
    return strategy:isValid()
  end)

  strategy:fire()

  if operator then
    return operator.getModeForTransition()
  else
    return motion.getModeForTransition()
  end
end

return Vim
