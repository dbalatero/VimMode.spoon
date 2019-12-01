local fnutils = require("hs.fnutils")
local keyUtils = {}

local shiftMaps = {
  ["1"] = "!",
  ["2"] = "@",
  ["3"] = "#",
  ["4"] = "$",
  ["5"] = "%",
  ["6"] = "^",
  ["7"] = "&",
  ["8"] = "*",
  ["9"] = "(",
  ["0"] = ")",
  a = "A",
  b = "B",
  c = "C",
  d = "D",
  e = "E",
  f = "F",
  g = "G",
  h = "H",
  i = "I",
  j = "J",
  k = "K",
  l = "L",
  m = "M",
  n = "N",
  o = "O",
  p = "P",
  q = "Q",
  r = "R",
  s = "S",
  t = "T",
  u = "U",
  v = "V",
  w = "W",
  x = "X",
  y = "Y",
  z = "Z",
}

local normalMaps = {
  escape = "<esc>",
  ["return"] = "⏎",
  left = "←",
  right = "→",
  up = "⇡",
  down = "↓",
  cmd = "⌘",
  alt = "⌥",
  ctrl = "⌃",
  shift = "⇧",
}

keyUtils.getRealChar = function(mods, key)
  local hasShift = fnutils.contains(mods, 'shift')

  if hasShift then
    return shiftMaps[key] or key
  else
    return normalMaps[key] or key
  end
end

return keyUtils
