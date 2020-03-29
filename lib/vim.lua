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

local function alertDeprecation(msg)
  hs.alert.show(
    "Deprecated: " .. msg,
    {},
    hs.screen.mainScreen(),
    15
  )
end

--------------------------------------------

local KeySequence = dofile(vimModeScriptPath .. "lib/key_sequence.lua")
local State = dofile(vimModeScriptPath .. "lib/state.lua")

function VimMode:new()
  local vim = {}

  setmetatable(vim, self)
  self.__index = self

  vim.state = State:new()

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

---------------------------

function VimMode:shouldShowAlertInNormalMode(showAlert)
  -- self.config.shouldShowAlertInNormalMode = showAlert
  return self
end

function VimMode:shouldDimScreenInNormalMode(shouldDimScreen)
  -- self.config.shouldDimScreenInNormalMode = shouldDimScreen
  return self
end

function VimMode:disableForApp(appName)
  -- self.appWatcher:disableApp(appName)

  return self
end

function VimMode:disable()
  self.state:disable()
  self:disableSequence()

  return self
end

function VimMode:enable()
  self.state:enable()
  self:enableSequence()

  return self
end

function VimMode:enter()
  self.state:enterNormalMode()

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

function VimMode:setAlertFont(name)
  -- self.config.alert.font = name

  return self
end

return VimMode
