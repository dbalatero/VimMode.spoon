local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")
local BackwardSearch = dofile(vimModeScriptPath .. "lib/motions/backward_search.lua")
local TillAfterSearch = dofile(vimModeScriptPath .. "lib/motions/till_after_search.lua")
local TillBeforeSearch = dofile(vimModeScriptPath .. "lib/motions/till_before_search.lua")

local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local RepeatSearchOpposite = Motion:new{ name = 'left' }

local charToMotion = {
  ["f"] = BackwardSearch,
  ["F"] = ForwardSearch,
  ["t"] = TillAfterSearch,
  ["T"] = TillBeforeSearch,
}

function RepeatSearchOpposite:getRange(buffer)
  local lastInlineSearch = buffer.vim.commandState.lastInlineSearch

  if lastInlineSearch == nil then
    return nil
  end

  local MatchedMotion = charToMotion[lastInlineSearch.search]

  if MatchedMotion then
    local motionWithExtraChar =
      MatchedMotion:new():setExtraChar(lastInlineSearch.char)

    return motionWithExtraChar:getRange(buffer, { isRepeated = true, isReversed = true })
  end
end

function RepeatSearchOpposite.getMovements()
  return nil
end

return RepeatSearchOpposite
