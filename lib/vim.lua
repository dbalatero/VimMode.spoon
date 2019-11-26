local VimMode = {
  author = "David Balatero <dbalatero@gmail.com>",
  homepage = "https://github.com/dbalatero/VimMode.spoon",
  license = "ISC",
  name = "VimMode",
  version = "1.0.0",
  spoonPath = vimModeScriptPath
}

---------------------------------------------

vimLogger = hs.logger.new('vim', 'debug')

-- Push ./vendor to the load path
package.path = vimModeScriptPath .. "vendor/?/init.lua;" .. package.path
package.cpath = vimModeScriptPath .. "vendor/?.so;" .. package.cpath

local ax = require("hs._asm.axuielement")

dofile(vimModeScriptPath .. "lib/utils/benchmark.lua")

local AccessibilityStrategy = dofile(vimModeScriptPath .. "lib/strategies/accessibility_strategy.lua")
local Alert = dofile(vimModeScriptPath .. "lib/alert.lua")
local AppWatcher = dofile(vimModeScriptPath .. "lib/app_watcher.lua")
local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")
local Config = dofile(vimModeScriptPath .. "lib/config.lua")
local ContextualModal = dofile(vimModeScriptPath .. "lib/contextual_modal.lua")
local KeySequence = dofile(vimModeScriptPath .. "lib/key_sequence.lua")
local KeyboardStrategy = dofile(vimModeScriptPath .. "lib/strategies/keyboard_strategy.lua")
local RestrictedModal = dofile(vimModeScriptPath .. "lib/restricted_modal.lua")
local ScreenDimmer = dofile(vimModeScriptPath .. "lib/screen_dimmer.lua")
local WaitForChar = dofile(vimModeScriptPath .. "lib/wait_for_char.lua")

local BackWord = dofile(vimModeScriptPath .. "lib/motions/back_word.lua")
local BigWord = dofile(vimModeScriptPath .. "lib/motions/big_word.lua")
local CurrentSelection = dofile(vimModeScriptPath .. "lib/motions/current_selection.lua")
local EndOfWord = dofile(vimModeScriptPath .. "lib/motions/end_of_word.lua")
local EntireLine = dofile(vimModeScriptPath .. "lib/motions/entire_line.lua")
local FirstLine = dofile(vimModeScriptPath .. "lib/motions/first_line.lua")
local FirstNonBlank = dofile(vimModeScriptPath .. "lib/motions/first_non_blank.lua")
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
local Replace = dofile(vimModeScriptPath .. "lib/operators/replace.lua")
local Yank = dofile(vimModeScriptPath .. "lib/operators/yank.lua")

local createStateMachine = dofile(vimModeScriptPath .. "lib/state.lua")
local findFirst = dofile(vimModeScriptPath .. "lib/utils/find_first.lua")

function VimMode:new()
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
  vim.visualCaretPosition = nil
  vim.modal = vim:buildModal()

  vim.appWatcher = AppWatcher:new(vim):start()

  return vim
end

-- Spoon API conformity

-- Allows binding entering normal mode to a hot key
--
-- vim:bindHotKeys({ enter = { {'cmd', 'shift'}, 'v' } })
function VimMode:bindHotKeys(keyTable)
  if keyTable.enter then
    local enter = keyTable.enter

    hs.hotkey.bind(enter[1], enter[2], function()
      self:enter()
    end)
  end

  return self
end

function VimMode:isMode(name)
  return self.mode == name
end

---------------------------

local function createVimModal()
  local modal = hs.hotkey.modal.new()

  modal.bindWithRepeat = function(mdl, mods, key, fn)
    local message = nil

    return mdl:bind(mods, key, message, fn, fn, fn)
  end

  return modal
end

function VimMode:shouldShowAlertInNormalMode(showAlert)
  self.config.shouldShowAlertInNormalMode = showAlert
  return self
end

function VimMode:shouldDimScreenInNormalMode(shouldDimScreen)
  self.config.shouldDimScreenInNormalMode = shouldDimScreen
  return self
end

function VimMode:disableForApp(appName)
  self.appWatcher:disableApp(appName)

  return self
end

function VimMode:disable()
  self.enabled = false
  self:disableSequence()

  return self
end

function VimMode:enable()
  self.enabled = true
  self:enableSequence()
  self:resetCommandState()

  return self
end

function VimMode:resetCommandState()
  self.commandState = CommandState:new()
end

function VimMode:operator(type)
  return function()
    self.state:enterOperator(type:new())
  end
end

function VimMode:cancel()
  self.state:enterNormal()
end

function VimMode:operatorNeedingChar(type, optionalMotion)
  return function()
    self:exitAllModals()
    vimLogger.i("waiting on char...")

    local waiter = WaitForChar:new{
      onCancel = function()
        vimLogger.i("onCancel()")
        self:cancel()
      end,
      onChar = function(character)
        local operator = type:new()
        operator:setExtraChar(character)

        vimLogger.i("Got a character " .. character .. " for " .. operator.name)

        self.state:enterOperator(operator)

        if optionalMotion then
          self.state:enterMotion(optionalMotion:new())
        end
      end
    }

    waiter:start()
  end
end

function VimMode:motion(type)
  return function()
    self.state:enterMotion(type:new())
  end
end

function VimMode:visualOperator(type)
  return function()
    self:operator(type:new())()
    self:motion(CurrentSelection:new())()
  end
end

function VimMode:buildModal()
  local modal = ContextualModal:new()

  -- g prefixes
  modal:withContext('g')
    :bind({}, 'escape', function() self:exit() end)
    :bind({}, 'g', self:motion(FirstLine))

  -- Visual mode
  modal:withContext('visual')
  self:bindMotionsToModal(modal)

  modal
    :bind({}, 'escape', function()
      self.state:enterNormal()
      self.visualCaretPosition = nil
    end)
    :bind({}, 'c', self:visualOperator(Delete))
    :bind({}, 'd', self:visualOperator(Delete))
    :bind({}, 'r', nil, self:operatorNeedingChar(Replace, CurrentSelection))
    :bind({}, 'x', self:visualOperator(Delete))
    :bind({}, 'y', self:visualOperator(Yank))

  -- Operator pending
  modal:withContext('operatorPending')
  self:bindMotionsToModal(modal, 'motion')
  self:bindCountsToModal(modal, 'motion')

  modal
    :bind({}, 'escape', function() self:cancel() end)
    :bind({}, 'c', self:motion(EntireLine)) -- cc
    :bind({}, 'd', self:motion(EntireLine)) -- dd

  -- Normal mode
  modal:withContext('normal')
  self:bindMotionsToModal(modal, 'operator')
  self:bindCountsToModal(modal, 'operator')

  modal
    :bind({}, 'i', function() self:exit() end)
    :bind({}, 'c', self:operator(Change))
    :bind({}, 'd', self:operator(Delete))
    :bind({}, 'y', self:operator(Yank))
    :bind({}, 'r', self:operatorNeedingChar(Replace, Right))
    :bind({}, 'v', function()
      self.state:enterVisual()
    end)
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
    :bind({'shift'}, 'i', function()
      self:motion(LineBeginning)()
      self:motion(FirstNonBlank)()
      self:exit()
    end)
    :bindWithRepeat({}, 'x', function()
      self:operator(Delete)()
      self:motion(Right)()
    end)
    :bindWithRepeat({}, 's', function()
      self:operator(Change)()
      self:motion(Right)()
    end)

    :withContext('operatorPending')
      :bind({}, 'escape', function() self:exit() end)
      :bindWithRepeat({}, 'b', self:motion(BackWord))
      :bindWithRepeat({}, 'w', self:motion(Word))

  return modal
end

-- type is either 'motion' or 'operator'
function VimMode:bindMotionsToModal(modal, type)
  return modal
    :bindWithRepeat({}, '0', function()
      -- we've already started adding a count here
      if self.commandState:getCount(type) then
        self:pushDigitTo(type, 0)()
      else
        self:motion(LineBeginning)()
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

function VimMode:pushDigitTo(name, digit)
  return function()
    self.commandState:pushCountDigit(name, digit)
    vimLogger.i("Count is now " .. self.commandState:getCount(name))
  end
end

function VimMode:bindCountsToModal(modal, name)
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

function VimMode:enableKeySequence(key1, key2, modifiers)
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

function VimMode:disableSequence()
  if not self.sequence then return end
  self.sequence:disable()
end

function VimMode:enableSequence()
  if not self.sequence then return end
  self.sequence:enable()
end

function VimMode:exit()
  vimLogger.i("calling it")
  self.state:enterInsert()
end

function VimMode:setInsertMode()
  self.mode = "insert"

  if self:shouldDimScreen() then ScreenDimmer.restoreScreen() end

  return self
end

function VimMode:setNormalMode()
  self.mode = "normal"

  if self:shouldDimScreen() then ScreenDimmer.dimScreen() end

  return self
end

function VimMode:setVisualMode()
  if not self:isMode('visual') then
    self.mode = 'visual'
    self.visualCaretPosition = nil
  end

  return self
end

function VimMode:shouldDimScreen()
  return not not self.config.shouldDimScreenInNormalMode
end

function VimMode:enter()
  if self.enabled then
    vimLogger.i("Entering Vim")
    self:showAlert()
    self.state:enterNormal()
  end
end

function VimMode:exitAllModals()
  self.modal:exit()
end

function VimMode:enterModal(name)
  vimLogger.i("Entering modal " .. name)
  self.modal:enterContext(name)
end

function VimMode:collapseSelection()
  if not self.visualCaretPosition then return end

  local strategy = AccessibilityStrategy:new(self)
  if not strategy:isValid() then return end

  strategy:setSelection(self.visualCaretPosition, 0)
end

function VimMode:fireCommandState()
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

  local transition

  if operator then
    transition = operator.getModeForTransition()
  else
    transition = motion.getModeForTransition()
  end

  return {
    mode = self.mode,
    transition = transition,
    hadMotion = not not motion,
    hadOperator = not not operator
  }
end

function VimMode:showAlert()
  if self.config.shouldShowAlertInNormalMode then
    self.alert:show(self.config)
  end
end

function VimMode:hideAlert()
  self.alert:hide()
end

function VimMode:setAlertFont(name)
  self.config.alert.font = name
end

return VimMode
