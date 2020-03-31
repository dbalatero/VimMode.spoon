local ChildProcessStream = require('nvim.child_process_stream')
local Session = require('nvim.session')

local Buffer = dofile(vimModeScriptPath .. "lib/nvim/buffer.lua")
local WrappedSession = dofile(vimModeScriptPath .. "lib/nvim/wrapped_session.lua")

local Editor = {}

local modeMap = {
  n = "normal",
  i = "insert",
  v = "visual"
}

function Editor:new()
  local editor = {}

  setmetatable(editor, self)
  self.__index = self

  editor.session = WrappedSession:new()
  editor.mainBuffer = Buffer:new(editor.session):focus()

  return editor
end

function Editor:getMainBuffer()
  return self.mainBuffer
end

function Editor:getMode()
  local _, result = self.session:request("nvim_get_mode")
  return modeMap[result.mode]
end

function Editor:isAwaitingInput()
  local _, result = self.session:request("nvim_get_mode")
  return result.blocking
end

function Editor:sendKeys(keys, onNotification)
  -- If true, escape K_SPECIAL/CSI bytes in `keys`
  -- TODO: figure out what the hell that even means (:h nvim_feedkeys)
  local escapeCsi = false

  self.session:request("nvim_feedkeys", keys, "n", escapeCsi)
  self.session:drainNotifications(onNotification)
end

return Editor
