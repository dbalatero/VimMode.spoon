local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")
local KeySequence = {}

function KeySequence:new(keys, onSequencePressed)
  local sequence = {}

  setmetatable(sequence, self)
  self.__index = self

  sequence.keys = stringUtils.toChars(keys)
  sequence.maxDelayBetweenKeys = 100 -- in ms
  sequence.onSequencePressed = onSequencePressed
  sequence.enabled = false
  sequence.timer = nil
  sequence.sequencePosition = 1
  sequence.typedEvents = {}
  sequence.alreadyTyped = ""
  sequence:resetTap()

  return sequence
end

function KeySequence:enable()
  if self.enabled then return end

  self.enabled = true
  self:reset()
  self.tap:start()

  return self
end

function KeySequence:disable()
  if not self.enabled then return end

  self.enabled = false
  self:reset()
  self.tap:stop()

  return self
end

function KeySequence:resetTap()
  self.tap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown },
    self:buildEventHandler()
  )
end

function KeySequence:reset()
  self:cancelTimer()
  self:resetEvents()
  self.sequencePosition = 1
  self.alreadyTyped = ""
end

function KeySequence:resetEvents()
  self.typedEvents = {}
  return self
end

function KeySequence:cancelTimer()
  if self.timer then self.timer:stop() end
end

function KeySequence:startTimer(fn)
  self.timer = hs.timer.doAfter(self.maxDelayBetweenKeys / 1000, fn)
end

function KeySequence:recordEvent(event)
  local currentModifiers = event:getFlags()
  local currentKey = event:getKeyCode()

  table.insert(
    self.typedEvents,
    hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, true)
  )

  table.insert(
    self.typedEvents,
    hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, false)
  )
end

function KeySequence:recordKey(key)
  self.alreadyTyped = self.alreadyTyped .. key
end

local function getTableSize(t)
  local count = 0
  for _, __ in pairs(t) do count = count + 1 end

  return count
end

function KeySequence:buildEventHandler()
  return function(event)
    if not self.enabled then return end

    -- got another key, kill the abort timer
    self:cancelTimer()

    local position = self.sequencePosition
    local keyPressed = hs.keycodes.map[event:getKeyCode()]
    local keyToCompare = self.keys[position]

    if keyPressed == keyToCompare and getTableSize(event:getFlags()) == 0 then
      local typedFinalChar = position == #self.keys

      if typedFinalChar then
        self:disable()
        self.onSequencePressed()
      else
        self.sequencePosition = position + 1
        self:recordEvent(event)
        self:recordKey(keyPressed)

        self:startTimer(function()
          self.tap:stop()
          hs.eventtap.keyStrokes(self.alreadyTyped)
          self.tap:start()

          self:reset()
        end)
      end

      return true
    elseif self.sequencePosition > 1 then
      -- Abort the sequence and pass through any keys we already typed
      self:recordEvent(event)
      local events = self.typedEvents

      self:reset()

      return true, events
    end

    return false
  end
end

return KeySequence
