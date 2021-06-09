local prequire = dofile(vimModeScriptPath .. "lib/utils/prequire.lua")

local function loadVendored()
  local arch = hs.execute("uname -p")

  if arch == "arm\n" then
    return require("luautf8.lua-utf8-arm")
  else
    return require("luautf8.lua-utf8-x86")
  end
end

-- Try to load it from luarocks, otherwise require the vendored version.
local luautf8 = prequire("lua-utf8") or loadVendored()

return luautf8
