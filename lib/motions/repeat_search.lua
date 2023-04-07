local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")
local BackwardSearch = dofile(vimModeScriptPath .. "lib/motions/backward_search.lua")
local TillAfterSearch = dofile(vimModeScriptPath .. "lib/motions/till_after_search.lua")
local TillBeforeSearch = dofile(vimModeScriptPath .. "lib/motions/till_before_search.lua")

local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local RepeatSearch = Motion:new{ name = 'left' }

local charToMotion = {
  ["f"] = ForwardSearch,
  ["F"] = BackwardSearch,
  ["t"] = TillBeforeSearch,
  ["T"] = TillAfterSearch,
}

function RepeatSearch:getRange(buffer)
  local lastInlineSearch = buffer.vim.commandState.lastInlineSearch

  if lastInlineSearch == nil then
    return nil
  end

  local MatchedMotion = charToMotion[lastInlineSearch.search]

  if MatchedMotion then
    local motionWithExtraChar =
      MatchedMotion:new():setExtraChar(lastInlineSearch.char)

    return motionWithExtraChar:getRange(buffer, { isRepeated = true })
  end
end

function RepeatSearch.getMovements()
  return nil
end

return RepeatSearch
