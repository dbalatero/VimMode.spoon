local ax = require("hs._asm.axuielement")

dofile(vimModeScriptPath .. "lib/utils/benchmark.lua")

local AccessibilityStrategy = dofile(vimModeScriptPath .. "lib/strategies/accessibility_strategy.lua")
local Alert = dofile(vimModeScriptPath .. "lib/alert.lua")
local AppWatcher = dofile(vimModeScriptPath .. "lib/app_watcher.lua")
local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")
local Config = dofile(vimModeScriptPath .. "lib/config.lua")
local KeySequence = dofile(vimModeScriptPath .. "lib/key_sequence.lua")
local KeyboardStrategy = dofile(vimModeScriptPath .. "lib/strategies/keyboard_strategy.lua")
local ScreenDimmer = dofile(vimModeScriptPath .. "lib/screen_dimmer.lua")

local BackWord = dofile(vimModeScriptPath .. "lib/motions/back_word.lua")
local BigWord = dofile(vimModeScriptPath .. "lib/motions/big_word.lua")
local EndOfWord = dofile(vimModeScriptPath .. "lib/motions/end_of_word.lua")
local EntireLine = dofile(vimModeScriptPath .. "lib/motions/entire_line.lua")
local FirstLine = dofile(vimModeScriptPath .. "lib/motions/first_line.lua")
local LastLine = dofile(vimModeScriptPath .. "lib/motions/last_line.lua")
local LineBeginning = dofile(vimModeScriptPath .. "lib/motions/line_beginning.lua")
local LineEnd = dofile(vimModeScriptPath .. "lib/motions/line_end.lua")
local Word = dofile(vimModeScriptPath .. "lib/motions/word.lua")

local Left = dofile(vimModeScriptPath .. "lib/motions/left.lua")
local Right = dofile(vimModeScriptPath .. "lib/motions/right.lua")
local Up = dofile(vimModeScriptPath .. "lib/motions/up.lua")
local Down = dofile(vimModeScriptPath .. "lib/motions/down.lua")

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

local function findFirst(list, fn)
  for _, item in ipairs(list) do
    if fn(item) then return item end
  end

  return nil
end

function Vim:new()
  local vim = {}

  setmetatable(vim, self)
  self.__index = self

  vim:resetCommandState()

  vim.alert = Alert:new()
  vim.config = Config:new()
  vim.enabled = true
  vim.mode = 'insert'
  vim.state = createStateMachine(vim)
  vim.sequence = nil

  vim.modals = {
    normal = vim:buildNormalModeModal(),
    operatorPending = vim:buildOperatorPendingModal(),
    g = vim:buildGModal()
  }

  vim.appWatcher = AppWatcher:new(vim):start()

  return vim
end

function Vim:shouldShowAlertInNormalMode(showAlert)
  self.config.shouldShowAlertInNormalMode = showAlert
  return self
end

function Vim:shouldDimScreenInNormalMode(shouldDimScreen)
  self.config.shouldDimScreenInNormalMode = shouldDimScreen
  return self
end

function Vim:disableForApp(appName)
  self.appWatcher:disableApp(appName)

  return self
end

function Vim:disable()
  self.enabled = false
  self:disableSequence()

  return self
end

function Vim:enable()
  self.enabled = true
  self:enableSequence()
  self:resetCommandState()

  return self
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

-- commands prefixed with g
function Vim:buildGModal()
  return createVimModal()
    :bind({}, 'ESCAPE', function() self:exit() end)
    :bind({}, 'g', nil, self:motion(FirstLine))
end

-- type is either 'motion' or 'operator'
function Vim:bindMotionsToModal(modal, type)
  return modal
    :bindWithRepeat({}, '0', function()
      -- we've already started adding a count here
      if self.commandState:getCount(type) then
        self:pushDigitTo(type, 0)()
      else
        self:motion(LineBeginning)
      end
    end)
    :bindWithRepeat({'shift'}, '4', self:motion(LineEnd)) -- $
    :bindWithRepeat({}, 'b', self:motion(BackWord))
    :bindWithRepeat({}, 'e', self:motion(EndOfWord))
    :bindWithRepeat({}, 'h', self:motion(Left))
    :bindWithRepeat({}, 'j', self:motion(Down))
    :bindWithRepeat({}, 'k', self:motion(Up))
    :bindWithRepeat({}, 'l', self:motion(Right))
    :bindWithRepeat({}, 'w', self:motion(Word))
    :bindWithRepeat({'shift'}, 'w', self:motion(BigWord))
    :bindWithRepeat({'shift'}, 'g', self:motion(LastLine))
    :bind({}, 'g', function() self:enterModal('g') end)
end

function Vim:pushDigitTo(name, digit)
  return function()
    self.commandState:pushCountDigit(name, digit)
    vimLogger.i("Count is now " .. self.commandState:getCount(name))
  end
end

function Vim:bindCountsToModal(modal, name)
  return modal
    :bindWithRepeat({}, '1', self:pushDigitTo(name, 1))
    :bindWithRepeat({}, '2', self:pushDigitTo(name, 2))
    :bindWithRepeat({}, '3', self:pushDigitTo(name, 3))
    :bindWithRepeat({}, '4', self:pushDigitTo(name, 4))
    :bindWithRepeat({}, '5', self:pushDigitTo(name, 5))
    :bindWithRepeat({}, '6', self:pushDigitTo(name, 6))
    :bindWithRepeat({}, '7', self:pushDigitTo(name, 7))
    :bindWithRepeat({}, '8', self:pushDigitTo(name, 8))
    :bindWithRepeat({}, '9', self:pushDigitTo(name, 9))
end

function Vim:buildOperatorPendingModal()
  local modal = self:bindMotionsToModal(createVimModal())
  modal = self:bindCountsToModal(modal, 'motion')

  return modal
    :bind({}, 'ESCAPE', function() self:exit() end)
    :bind({}, 'c', self:motion(EntireLine)) -- cc
    :bind({}, 'd', self:motion(EntireLine)) -- dd
end

function Vim:buildNormalModeModal()
  local modal = self:bindMotionsToModal(createVimModal())
  modal = self:bindCountsToModal(modal, 'operator')

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
    :bindWithRepeat({}, 's', function()
      self:operator(Change)()
      self:motion(Right)()
    end)
end

function Vim:enableKeySequence(key1, key2, modifiers)
  modifiers = modifiers or {}

  local onSequencePressed = function()
    self:enter()
  end

  self.sequence = KeySequence
    :new{ key1 = key1, key2 = key2, modifiers = modifiers }
    :setOnSequencePressed(onSequencePressed)
    :enable()

  return self
end

function Vim:disableSequence()
  if not self.sequence then return end
  self.sequence:disable()
end

function Vim:enableSequence()
  if not self.sequence then return end
  self.sequence:enable()
end

function Vim:exit()
  self.state:enterInsert()
end

function Vim:setInsertMode()
  self.mode = "insert"

  if self:shouldDimScreen() then ScreenDimmer.restoreScreen() end

  return self
end

function Vim:setNormalMode()
  self.mode = "normal"

  if self:shouldDimScreen() then ScreenDimmer.dimScreen() end

  return self
end

function Vim:shouldDimScreen()
  return not not self.config.shouldDimScreenInNormalMode
end

function Vim:enter()
  if self.enabled then
    vimLogger.i("Entering Vim")
    self:showAlert()
    self.state:enterNormal()
  end
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

function Vim:showAlert()
  if self.config.shouldShowAlertInNormalMode then
    self.alert:show(self.config)
  end
end

function Vim:hideAlert()
  self.alert:hide()
end

function Vim:setAlertFont(name)
  self.config.alert.font = name
end

return Vim
