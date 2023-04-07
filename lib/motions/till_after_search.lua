local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local BackwardSearch = dofile(vimModeScriptPath .. "lib/motions/backward_search.lua")

local TillAfterSearch = Motion:new{ name = 'till_after_search' }

function TillAfterSearch:getRange(buffer, opts)
  local searchChar = self:getExtraChar()
  local motion = BackwardSearch:new():setExtraChar(searchChar)
  local startOffset = opts and opts.isRepeated and -1 or 0
  local range = motion:getRange(buffer, { startOffset = startOffset })

  buffer.vim.commandState:saveLastInlineSearch({
    search = opts and opts.isReversed and "t" or "T",
    char = searchChar,
  })

  if not range then return nil end

  -- go right after the search result
  range.start = range.start + 1

  -- don't overflow off the start
  range.start = math.min(buffer:getLength() -  1, range.start)

  return range
end

function TillAfterSearch.getMovements()
  return nil
end

return TillAfterSearch
