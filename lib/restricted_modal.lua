local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local RestrictedModal = {}
local unpack = table.unpack

function RestrictedModal:new(...)
  local restricted = {
    registeredKeys = {}
  }

  setmetatable(restricted, self)
  self.__index = self

  restricted.modal = hs.hotkey.modal.new(...)

  restricted.tap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown },
    function(event)
      return restricted:handleKeyPress(event)
    end
  )

  restricted.modal.entered = function()
    restricted.tap:start()
  end

  restricted.modal.exited = function()
    restricted.tap:stop()
  end

  return restricted
end

function RestrictedModal:bind(mods, key, ...)
  local keys = self.registeredKeys
  keys[key] = true

  self.modal:bind(mods, key, ...)

  return self
end

function RestrictedModal:bindWithRepeat(mods, key, fn)
  local message = nil

  return self:bind(mods, key, message, fn, fn, fn)
end

function RestrictedModal:enter()
  self.modal:enter()

  return self
end

function RestrictedModal:exit()
  self.modal:exit()

  return self
end

function RestrictedModal:handleKeyPress(event)
  local character = event:getCharacters()

  if self.registeredKeys[character] then
    return false
  elseif stringUtils.isNonAlphanumeric(character) then
    -- let alt+tab through
    return false
  else
    -- do not pass through
    return true
  end
end

return RestrictedModal
