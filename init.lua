local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

vimModeScriptPath = scriptPath()

local Vim = dofile(vimModeScriptPath .. "lib/vim.lua")

return Vim
