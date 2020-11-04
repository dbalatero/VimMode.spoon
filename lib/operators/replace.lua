local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local times = dofile(vimModeScriptPath .. "lib/utils/times.lua")
local Replace = Operator:new{name = 'replace'}
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

function Replace:modifySelection(_, rangeStart, rangeFinish)
  local numChars = rangeFinish - rangeStart + 1
  local replaceChar = self:getExtraChar()
  local replacement = ""

  times(numChars, function()
    replacement = replacement .. replaceChar
  end)

  hs.eventtap.keyStroke({}, 'delete', 50)
  hs.eventtap.keyStrokes(replacement)

  times(numChars, function()
    hs.eventtap.keyStroke({}, 'left', 0)
  end)
end

function Replace:getModifiedBuffer(buffer, rangeStart, rangeFinish)
  local value = buffer:getValue()
  local replaceChar = self:getExtraChar()

  local length = rangeFinish - rangeStart + 1

  local contents = ""
  local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1

  if stringStart > 1 then
    contents = utf8.sub(value, 1, stringStart - 1)
  end

  local numChars = rangeFinish - rangeStart + 1

  times(numChars, function()
    contents = contents .. replaceChar
  end)

  contents = contents .. utf8.sub(value, stringFinish + 1, -1)

  return buffer:createNew(contents, rangeStart, 0)
end

function Replace:getKeys()
  -- TODO support in bootleg mode
  return nil
end

return Replace
