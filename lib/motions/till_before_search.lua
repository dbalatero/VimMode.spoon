local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")

local TillBeforeSearch = Motion:new{ name = 'till_before_search' }

function TillBeforeSearch:getRange(buffer, opts)
  local searchChar = self:getExtraChar()
  local motion = ForwardSearch:new():setExtraChar(self:getExtraChar())
  local startOffset = opts and opts.isRepeated and 1 or 0
  local range = motion:getRange(buffer, { startOffset = startOffset })

  buffer.vim.commandState:saveLastInlineSearch({
    search = opts and opts.isReversed and "T" or "t",
    char = searchChar,
  })

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
