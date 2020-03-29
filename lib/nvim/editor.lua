local ChildProcessStream = require('nvim.child_process_stream')
local Session = require('nvim.session')

local Buffer = dofile(vimModeScriptPath .. "lib/nvim/buffer.lua")

local Editor = {}

function Editor:new()
  local editor = {}

  setmetatable(editor, self)
  self.__index = self

  editor.session = Session.new(
    ChildProcessStream.spawn({
      '/usr/local/bin/nvim',
      '-u',
      'NONE',
      '--embed',
      '--headless'
    })
  )

  editor.mainBuffer = Buffer:new(editor.session):focus()

  return editor
end

function Editor:getMainBuffer()
  return self.mainBuffer
end

function Editor:sendKeys(keys)
  -- If true, escape K_SPECIAL/CSI bytes in `keys`
  -- TODO: figure out what the hell that even means (:h nvim_feedkeys)
  local escapeCsi = false

  self.session:request("nvim_feedkeys", keys, "n", escapeCsi)
end

function Editor:__gc()
  self.session:stop()
end

return Editor
