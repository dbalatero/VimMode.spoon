-- Provides an object for binding specific key sequences
local KeySequence = {}

function KeySequence:new(options)
  options = options or {}

  local sequence = {}

  setmetatable(sequence, self)
  self.__index = self

  sequence.key1 = options.key1
  sequence.key2 = options.key2
  sequence.modifiers = options.modifiers or {}
  sequence.maxDelayBetweenKeys = 200
  sequence.waitingForSecondPress = false
  sequence.tap = nil
  sequence.onSequencePressed = function() end
  sequence.enabled = false

  sequence:initializeTap()

  return sequence
end

function KeySequence:initializeTap()
  self.tap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown },
    function(event)
      if not self.enabled then return end

      local hasModifiers = event:getFlags():containExactly(self.modifiers)
      local keyPressed = hs.keycodes.map[event:getKeyCode()]

      if not self.waitingForSecondPress then
        -- handle first key press
        if hasModifiers and keyPressed == self.key1 then
          self.waitingForSecondPress = true

          -- cancel waiting for the key press after a given timeout
          hs.timer.doAfter(self.maxDelayBetweenKeys / 1000, function()
            if not self.waitingForSecondPress then return end

            self.waitingForSecondPress = false

            self.tap:stop()
            hs.eventtap.keyStroke(self.modifiers, self.key1, 0)
            self.tap:start()
          end)

          return true
        end
      else
        -- handle second key press
        self.waitingForSecondPress = false

        if hasModifiers and keyPressed == self.key2 then
          -- successful sequence!
          self:disable()
          self.onSequencePressed()

          return true
        else
          -- Pass thru the first key as well as the second one if we aren't
          -- typing the sequence.
          local currentModifiers = event:getFlags()
          local currentKey = event:getKeyCode()

          return true, {
            hs.eventtap.event.newKeyEvent(self.modifiers, self.key1, true),
            hs.eventtap.event.newKeyEvent(self.modifiers, self.key1, false),
            hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, true),
            hs.eventtap.event.newKeyEvent(currentModifiers, currentKey, false)
          }
        end
      end

      return false
    end
  )
end

function KeySequence:enable()
  self.enabled = true
  self.tap:start()

  return self
end

function KeySequence:disable()
  self.enabled = false
  self.tap:stop()

  return self
end

function KeySequence:setOnSequencePressed(fn)
  self.onSequencePressed = fn
  return self
end

return KeySequence
