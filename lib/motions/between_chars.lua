local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local BackwardSearch = dofile(vimModeScriptPath .. "lib/motions/backward_search.lua")
local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")

local BetweenChars = Motion:new{ name = 'between_chars' }

function BetweenChars:setSearchChars(beginningChar, endingChar)
  self.beginningChar = beginningChar
  self.endingChar = endingChar
end

function BetweenChars:getRange(buffer)
  if not self.beginningChar or not self.endingChar then
    error("Please setSearchChars(..., ...)")
  end

  local currentChar = buffer:currentChar()

  local start = nil

  if currentChar == self.beginningChar then
    start = buffer:getCaretPosition()
  end

  if not start then
    local backwardResult = BackwardSearch
      :new()
      :setExtraChar(self.beginningChar)
      :getRange(buffer)

    start = backwardResult and backwardResult.start
  end

  if not start then return nil end

  -- Find the finish position.
  local finish = nil

  if currentChar == self.endingChar then
    finish = buffer:getCaretPosition()
  end

  if not finish then
    local forwardResult = ForwardSearch
      :new()
      :setExtraChar(self.endingChar)
      :getRange(buffer)

    finish = forwardResult and forwardResult.finish
  end

  if not finish then return nil end

  return {
    start = start + 1,
    finish = finish - 1,
    mode = "inclusive",
    direction = "characterwise",
  }
end

function BetweenChars:getMovements()
  return nil
end

return BetweenChars
