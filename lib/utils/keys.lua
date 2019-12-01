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

-- Taken from https://wincent.com/wiki/Unicode_representations_of_modifier_keys
local normalMaps = {
  escape = "⎋",
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

-- Given a table of mods and a key pressed, convert it to a readable version
--
-- Examples:
--
--   getRealChar({'shift'}, '4') => "$"
--   getRealChar({'shift'}, 'h') => "H"
--   getRealChar({}, 'h') => "h"
keyUtils.getRealChar = function(mods, key)
  local hasShift = fnutils.contains(mods, 'shift')

  if hasShift then
    return shiftMaps[key] or key
  else
    return normalMaps[key] or key
  end
end

return keyUtils
