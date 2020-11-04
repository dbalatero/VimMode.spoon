local versionUtils = dofile(vimModeScriptPath .. "lib/utils/version.lua")

-- make this global so it only runs once
vimModeAxLibrary = nil

local function loadAxUiElement()
  if vimModeAxLibrary then return vimModeAxLibrary end

  -- support old versions of Hammerspoon that didn't have axuielement packaged.
  if versionUtils.hammerspoonVersionLessThan("0.9.79") then
    vimModeAxLibrary = require("hs._asm.axuielement")
  else
    -- use the built-in
    vimModeAxLibrary = require("hs.axuielement")
  end

  return vimModeAxLibrary
end

return loadAxUiElement()
