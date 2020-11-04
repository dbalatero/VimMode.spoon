local prequire = dofile(vimModeScriptPath .. "lib/utils/prequire.lua")

-- Try to load it from luarocks, otherwise require the vendored version.
local luautf8 = prequire("lua-utf8") or require("luautf8.lua-utf8")

return luautf8
