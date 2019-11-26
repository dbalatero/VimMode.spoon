local Set = dofile(vimModeScriptPath .. 'lib/utils/set.lua')

local tableUtils = {}

tableUtils.matches = function(table1, table2)
  if #table1 ~= #table2 then return false end

  local set = Set(table1)

  for _, value in pairs(table2) do
    if not set[value] then return false end
  end

  return true
end

return tableUtils
