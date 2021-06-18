local prequire = dofile(vimModeScriptPath .. "lib/utils/prequire.lua")

local function loadVendored()
  local arch = hs.execute("uname -p")

  if arch == "arm\n" then
    return require("luautf8.arm.lua-utf8")
  else
    return require("luautf8.x86.lua-utf8")
  end
end

-- Try to load it from luarocks, otherwise require the vendored version.
local luautf8 = prequire("lua-utf8") or loadVendored()

return luautf8
