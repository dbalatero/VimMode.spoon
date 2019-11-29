local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local times = dofile(vimModeScriptPath .. "lib/utils/times.lua")
local Replace = Operator:new{name = 'replace'}

function Replace:modifySelection(_, rangeStart, rangeFinish)
  local numChars = rangeFinish - rangeStart + 1
  local replaceChar = self:getExtraChar()
  local replacement = ""

  times(numChars, function()
    replacement = replacement .. replaceChar
  end)

  hs.eventtap.keyStroke({}, 'delete', 50)
  hs.eventtap.keyStrokes(replacement)
end

function Replace:getModifiedBuffer(buffer, rangeStart, rangeFinish)
  local value = buffer:getValue()
  local replaceChar = self:getExtraChar()

  local length = rangeFinish - rangeStart + 1

  local contents = ""
  local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1

  if stringStart > 1 then
    contents = string.sub(value, 1, stringStart - 1)
  end

  local numChars = rangeFinish - rangeStart + 1

  times(numChars, function()
    contents = contents .. replaceChar
  end)

  contents = contents .. string.sub(value, stringFinish + 1, -1)

  return buffer:createNew(contents, rangeStart, 0)
end

-- TODO
function Replace.getKeys()
  return {}
end

return Replace
