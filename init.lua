VimMode = {
  afterExitHooks = nil,
  commandState = nil,
  entered = false,
  enabled = true,
  mode = nil,
  sequence = nil
}

VimMode.name = "VimMode"
VimMode.version = "0.0.1"
VimMode.author = "David Balatero <dbalatero@gmail.com>"
VimMode.license = "ISC"

local function getSpoonPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

VimMode.spoonPath = getSpoonPath()

VimMode.requireFile = function(path)
  return dofile(VimMode.spoonPath..path..".lua")
end

local extendedModes = VimMode.requireFile('lib/extended-modes')
local motions = VimMode.requireFile('lib/motions')
local operators = VimMode.requireFile('lib/operators')
local utils = VimMode.requireFile('lib/utils')

local function compose(...)
  local fns = {...}

  return function()
    for _, fn in ipairs(fns) do
      fn()
    end
  end
end

VimMode.buildCommandState = function()
  return {
    selection = false,
    visualMode = false,
    operatorFn = nil,
    motionDirection = 'forward'
  }
end

VimMode.spoonPath = getSpoonPath()

VimMode.dimScreen = function()
  hs.screen.primaryScreen():setGamma(
    {red=1.0,green=1.0,blue=0.8},
    {alpha=1.0,blue=0.0,green=0.0,red=0.0}
  )
end

VimMode.restoreDim = function()
  hs.screen.restoreGamma()
end

VimMode.new = function()
  local self = utils.deepcopy(VimMode)

  self.afterExitHooks = {}
  self.commandState = VimMode.buildCommandState()
  self.entered = false
  self.enabled = true
  self.mode = hs.hotkey.modal.new()

  self.sequence = {
    tap = nil,
    waitingForPress = false
  }

  self.watchers = {}

  return self
end

function VimMode:init()
  self:bindModeKeys()
end

---------- toggling
function VimMode:enter()
  if self.enabled then
    self.mode:enter()

    self.entered = true
    self:resetState()

    VimMode.dimScreen()
  end
end

function VimMode:exit()
  self.mode:exit()

  VimMode.restoreDim()
  self.entered = false

  self:runAfterExitHooks()
end

function VimMode:disableForApp(disabledApp)
  local vim = self

  local watcher =
    hs.application.watcher.new(function(applicationName, eventType)
      if disabledApp ~= applicationName then return end

      if eventType == hs.application.watcher.activated then
        vim:exit()
        vim:disable()
      elseif eventType == hs.application.watcher.deactivated then
        vim:enable()
      end
    end)

  watcher:start()

  self.watchers[disabledApp] = watcher
end

---------- state

function VimMode:isSelection()
  return not not self.commandState.selection
end

function VimMode:isVisualMode()
  return not not self.commandState.visualMode
end

function VimMode:toggleVisualMode()
  self.commandState.visualMode = true
  self.commandState.selection = not self.commandState.selection
end

function VimMode:disable()
  self.enabled = false
end

function VimMode:enable()
  self:resetState()
  self.enabled = true
end

function VimMode:resetState()
  self.commandState = VimMode.buildCommandState()
end

---------- hooks

function VimMode:registerAfterExit(fn)
  table.insert(self.afterExitHooks, fn)
end

function VimMode:runAfterExitHooks()
  for _, fn in ipairs(self.afterExitHooks) do
    fn()
  end
end

---------- actions

function VimMode:runOperator()
  if self.commandState.operatorFn then
    self.commandState.operatorFn(self)
    self:resetState()
  end
end

function VimMode:restoreCursor()
  if self.commandState.motionDirection == 'forward' then
    utils.sendKeys({}, 'left')
  else
    utils.sendKeys({}, 'right')
  end
end

---------- key bindings

function VimMode:enableKeySequence(key1, key2, modifiers)
  modifiers = modifiers or {}

  local waitingForPress = false
  local maxDelay = 200

  self.sequence.tap = hs.eventtap.new(
    {hs.eventtap.event.types.keyDown},
    function(event)
      if not self.enabled or self.entered then
        return false
      end

      local hasModifiers = event:getFlags():containExactly(modifiers)
      local keyPressed = hs.keycodes.map[event:getKeyCode()]

      if hasModifiers and keyPressed == key1 then
        self.sequence.waitingForPress = true

        hs.timer.doAfter(maxDelay / 1000, function()
          if not self.sequence.waitingForPress then return end
          self.sequence.waitingForPress = false

          self.sequence.tap:stop()

          utils.sendKeys(modifiers, key1)

          self.sequence.tap:start()
        end)

        return true
      end

      if self.sequence.waitingForPress then
        self.sequence.waitingForPress = false

        if hasModifiers and keyPressed == key2 then
          self.sequence.tap:stop()
          self:enter()

          return true
        else
          -- Pass thru the first key as well as the second one if we aren't
          -- typing the sequence.
          local currentModifiers = event:getFlags()
          local currentKey = event:getKeyCode()

          return true, {
            hs.eventtap.event.newKeyEvent(modifiers, key1, true),
            hs.eventtap.event.newKeyEvent(modifiers, key1, false),
            hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, true),
            hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, false)
          }
        end
      end

      return false
    end
  )

  self:registerAfterExit(function()
    self.sequence.tap:start()
  end)

  self.sequence.tap:start()
end

function VimMode:bindModeKeys()
  local exit = function() self:exit() end

  local isNormalMode = function(fn)
    return function()
      if not self.commandState.visualMode then fn() end
    end
  end

  ------------ exiting
  self.mode:bind({}, 'i', exit)

  ------------ motions
  self.mode:bind({}, 'b', motions.backWord(self), nil, motions.backWord(self))
  self.mode:bind({}, 'w', motions.word(self), nil, motions.word(self))
  self.mode:bind({}, 'h', motions.left(self), nil, motions.left(self))
  self.mode:bind({}, 'j', motions.down(self), nil, motions.down(self))
  self.mode:bind({}, 'k', motions.up(self), nil, motions.up(self))
  self.mode:bind({}, 'l', motions.right(self), nil, motions.right(self))
  self.mode:bind({}, '0', motions.beginningOfLine(self), nil, motions.beginningOfLine(self))
  self.mode:bind({'shift'}, '4', motions.endOfLine(self), nil, motions.endOfLine(self))
  self.mode:bind({'shift'}, 'l', motions.endOfLine(self), nil, motions.endOfLine(self))
  self.mode:bind({'shift'}, 'g', motions.endOfText(self), nil, motions.endOfText(self))

  ------------ operators
  self.mode:bind({}, 'c', operators.change(self))
  self.mode:bind({}, 'd', operators.delete(self))
  self.mode:bind({}, 'y', operators.yank(self))

  ------------ shortcuts

  local paste = function()
    utils.sendKeys({'cmd'}, 'v')
  end

  local undo = function()
    utils.sendKeys({'cmd'}, 'z')
    self:restoreCursor()
  end

  local cutNext = function()
    if not self.commandState.visualMode then
      utils.sendKeys({'shift'}, 'right')
      utils.sendKeys({'cmd'}, 'x')
    else
      utils.sendKeys({'cmd'}, 'x')
    end
  end

  local cut = compose(
    cutNext,
    exit
  )

  local deleteUnderCursor = compose(
    operators.delete(self),
    isNormalMode(motions.right(self))
  )

  local searchAhead = function()
    utils.sendKeys({'command'}, 'f')
  end

  local newLineBelow = function()
    utils.sendKeys({'command'}, 'right')
    self:exit()
    utils.sendKeys({}, 'Return')
  end

  local newLineAbove = function()
    utils.sendKeys({'command'}, 'left')
    self:exit()
    utils.sendKeys({}, 'Return')
    utils.sendKeys({}, 'up')
  end

  self.mode:bind({'shift'}, 'a', compose(motions.endOfLine(self), exit))
  self.mode:bind({'shift'}, 'c', compose(operators.change(self), motions.endOfLine(self)))
  self.mode:bind({'shift'}, 'i', compose(motions.beginningOfLine(self), exit))
  self.mode:bind({'shift'}, 'd', compose(operators.delete(self), motions.endOfLine(self)))
  self.mode:bind({}, 's', compose(deleteUnderCursor, exit))
  --self.mode:bind({}, 'x', deleteUnderCursor)
  self.mode:bind({}, 'z', cutNext) -- works as expected, binding a non-x char ?!
  --self.mode:bind({}, 'x', cutNext) -- only selects, not cuts
  --self.mode:bind({'shift'}, 'x', cutNext) -- only selects, not cuts
  --self.mode:bind({}, 'x', compose(cutNext, motions.right(self))) -- test compose
  self.mode:bind({}, 'x', cut) -- test external `compose`: selects 1 char and exits VimMode

  self.mode:bind({}, 'o', newLineBelow)
  self.mode:bind({'shift'}, 'o', newLineAbove)
  self.mode:bind({}, 'p', paste)
  self.mode:bind({}, 'u', undo)

  ---------- commands
  self.mode:bind({}, '/', searchAhead)
  self.mode:bind({}, 'v', function() self:toggleVisualMode() end)
  self.mode:bind({}, 'r', extendedModes.replace(self))
end

return VimMode.new()
