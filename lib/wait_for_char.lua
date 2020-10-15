local WaitForChar = {}

function WaitForChar:new(options)
  options = options or {}

  local waiter = {
    onCancel = options.onCancel or function() end,
    onChar = options.onChar or function() end,
    tap = nil
  }

  setmetatable(waiter, self)
  self.__index = self

  return waiter
end

function WaitForChar:start()
  self.tap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown },
    function(event)
      local character = event:getCharacters()
      local escChar = ""

      if character == "" or character == escChar then
        self.onCancel()
      else
        self.onChar(character)
      end

      self.tap:stop()

      -- prevent any char passthru
      return true
    end
  )

  self.tap:start()
end

return WaitForChar
