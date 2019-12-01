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

local AccessibilityBuffer = dofile(vimModeScriptPath .. "lib/accessibility_buffer.lua")
local AccessibilityStrategy = dofile(vimModeScriptPath .. "lib/strategies/accessibility_strategy.lua")
local AppWatcher = dofile(vimModeScriptPath .. "lib/app_watcher.lua")
local CommandState = dofile(vimModeScriptPath .. "lib/command_state.lua")
local Config = dofile(vimModeScriptPath .. "lib/config.lua")
local KeySequence = dofile(vimModeScriptPath .. "lib/key_sequence.lua")
local KeyboardStrategy = dofile(vimModeScriptPath .. "lib/strategies/keyboard_strategy.lua")
local ScreenDimmer = dofile(vimModeScriptPath .. "lib/screen_dimmer.lua")
local StateIndicator = dofile(vimModeScriptPath .. "lib/state_indicator.lua")

local createHotPatcher = dofile(vimModeScriptPath .. "lib/hot_patcher.lua")
local createVimModal = dofile(vimModeScriptPath .. "lib/modal.lua")
local createStateMachine = dofile(vimModeScriptPath .. "lib/state.lua")
local findFirst = dofile(vimModeScriptPath .. "lib/utils/find_first.lua")
local keyUtils = dofile(vimModeScriptPath .. "lib/utils/keys.lua")

local function alertDeprecation(msg)
  hs.alert.show(
    "Deprecated: " .. msg,
    {},
    hs.screen.mainScreen(),
    15
  )
end

function VimMode:new()
  local vim = {}

  setmetatable(vim, self)
  self.__index = self

  vim:resetCommandState()

  vim.config = Config:new()
  vim.enabled = true
  vim.mode = 'insert'
  vim.modal = createVimModal(vim):setOnBeforePress(function(mods, key)
    local realKey = keyUtils.getRealChar(mods, key)
    vim.commandState:pushChar(realKey)
  end)

  vim.state = createStateMachine(vim)
  vim.sequence = nil
  vim.visualCaretPosition = nil

  vim.hotPatcher = createHotPatcher()
  vim.hotPatcher:start()

  vim.appWatcher = AppWatcher:new(vim):start()
  vim.stateIndicator = StateIndicator:new(vim):update()

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

function VimMode:updateStateIndicator()
  self.stateIndicator:update()

  return self
end

function VimMode:disable()
  self.enabled = false
  self:disableSequence()
  self:resetCommandState()

  return self
end

function VimMode:enable()
  self.enabled = true
  self:resetCommandState()
  self:enableSequence()

  return self
end

function VimMode:setPendingInput(value)
  self.commandState:setPendingInput(value)
  self:updateStateIndicator()

  return self
end

function VimMode:resetCommandState()
  self.commandState = CommandState:new()
end

function VimMode:enterOperator(operator)
  self.state:enterOperator(operator)
end

function VimMode:enterMotion(motion)
  self.state:enterMotion(motion)
end

function VimMode:cancel()
  self.state:enterNormal()
end

function VimMode:setVisualCaretPosition(position)
  self.visualCaretPosition = position
  return self
end

function VimMode:enterWithSequence(keys)
  self.sequence = KeySequence:new(keys, function()
    self:enter()
  end)

  self.sequence:enable()

  return self
end

-- Deprecated in favor of :enterWithSequence('jk'), etc
function VimMode:enableKeySequence(key1, key2)
  alertDeprecation(
    "vim:enableKeySequence('" .. key1 .. "', '" .. key2 .. "')\n" ..
      "Please use: vim:enterWithSequence('" .. key1 .. key2 .. "') to bind now.\n" ..
      "In: ~/.hammerspoon/init.lua"
  )

  self:enterWithSequence(key1 .. key2)

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
    self:collapseSelection()
    self.state:enterNormal()
  end
end

-- If we try to exit from the ContextualModal synchronously, we end
-- up in a bad state where the 'i' key just repeats forever.
--
-- If we can just chill for a couple ms this lets us exit the modal
-- key handler and move back to the key sequence tap.
--
-- Ugh.
function VimMode:exitAsync()
  local seconds = 3 / 1000 -- converting ms -> secs
  return hs.timer.doAfter(seconds, function() self:exit() end)
end

function VimMode:exitModalAsync()
  local seconds = 3 / 1000 -- converting ms -> secs
  return hs.timer.doAfter(seconds, function() self:exitAllModals() end)
end

function VimMode:canUseAdvancedMode()
  return AccessibilityBuffer:new():isValid()
end

function VimMode:exitAllModals()
  self.modal:exit()
end

function VimMode:enterModal(name)
  self.modal:enterContext(name)

  return self
end

function VimMode:collapseSelection()
  local strategy = AccessibilityStrategy:new(self)
  if not strategy:isValid() then return end

  if self.visualCaretPosition then
    strategy:setSelection(self.visualCaretPosition, 0)
  else
    local selection = strategy:getSelection()

    -- Only collapse if we have a selection
    if selection and selection:isSelected() then
      strategy:setSelection(selection.location, 0)
    end
  end
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

function VimMode:setAlertFont(name)
  self.config.alert.font = name

  return self
end

return VimMode
