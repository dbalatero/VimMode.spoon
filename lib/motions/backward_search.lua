local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local BackwardSearch = Motion:new{ name = 'backward_search' }

function BackwardSearch:getRange(buffer, opts)
  local finish = buffer:getCaretPosition()
  local stringFinish = finish + (opts and opts.startOffset or 0) + 1
  local searchChar = self:getExtraChar()

  local prevOccurringIndex = stringUtils.findPrevIndex(
    buffer:getValue(),
    searchChar,
    stringFinish - 1 -- start from the prev char
  )

  buffer.vim.commandState:saveLastInlineSearch({
    search = opts and opts.isReversed and "f" or "F",
    char = searchChar,
  })

  if not prevOccurringIndex then return nil end

  return {
    start = prevOccurringIndex - 1,
    finish = finish,
    mode = 'exclusive',
    direction = 'characterwise'
  }
end

function BackwardSearch.getMovements()
  return nil
end

return BackwardSearch
