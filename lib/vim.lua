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
local KeySequence = dofile(vimModeScriptPath .. "lib/key_sequence.lua")
local KeyboardStrategy = dofile(vimModeScriptPath .. "lib/strategies/keyboard_strategy.lua")
local ScreenDimmer = dofile(vimModeScriptPath .. "lib/screen_dimmer.lua")

local createVimModal = dofile(vimModeScriptPath .. "lib/modal.lua")
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
  vim.modal = createVimModal(vim)

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
  self:resetCommandState()

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

function VimMode:canUseAdvancedMode()
  return AccessibilityBuffer:new():isValid()
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

  return self
end

return VimMode
