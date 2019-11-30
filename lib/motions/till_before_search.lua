local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")

local TillBeforeSearch = Motion:new{ name = 'till_before_search' }

function TillBeforeSearch:getRange(buffer, ...)
  local motion = ForwardSearch:new():setExtraChar(self:getExtraChar())
  local range = motion:getRange(buffer, ...)

  if not range then return nil end

  -- go right before the search result
  range.finish = range.finish - 1

  -- don't overflow
  range.finish = math.max(0, range.finish)

  return range
end

function TillBeforeSearch.getMovements()
  return nil
end

return TillBeforeSearch
