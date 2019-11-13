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
  local operator = function(type)
    return function()
      self.state:enterOperator(type:new())
    end
  end

  local motion = function(type)
    return function()
      self.state:enterMotion(type:new())
    end
  end

  local alias = function(keys)
    return function()
      hs.eventtap.keyStrokes(keys)
    end
  end

  local modal = hs.hotkey.modal.new()

  modal.bindWithRepeat = function(mdl, mods, key, fn)
    local message = nil

    return mdl:bind(mods, key, message, fn, fn, fn)
  end

  return modal
    :bind({}, 'i', function() self:exit() end)
    :bind({}, 'c', nil, operator(Change))
    :bind({}, 'd', nil, operator(Delete))
    :bind({'shift'}, 'a', function()
      motion(LineEnd)()
      self:exit()
    end)
    :bind({'shift'}, 'c', function()
      operator(Change)()
      motion(LineEnd)()
    end)
    :bind({'shift'}, 'd', function()
      operator(Delete)()
      motion(LineEnd)()
    end)
    :bindWithRepeat({}, '0', motion(LineBeginning))
    :bindWithRepeat({'shift'}, '4', motion(LineEnd)) -- $
    :bindWithRepeat({}, 'b', motion(BackWord))
    :bindWithRepeat({}, 'e', motion(EndOfWord))
    :bindWithRepeat({}, 'h', motion(Left))
    :bindWithRepeat({}, 'l', motion(Right))
    :bindWithRepeat({}, 'w', motion(Word))
    :bindWithRepeat({'shift'}, 'w', motion(BigWord))
    :bindWithRepeat({}, 'x', function()
      operator(Delete)()
      motion(Right)()
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
