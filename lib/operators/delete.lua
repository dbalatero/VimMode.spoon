local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local Delete = Operator:new{name = 'delete'}

function Delete.getModifiedBuffer(buffer, rangeStart, rangeFinish)
  local length = rangeFinish - rangeStart + 1

  local contents = ""
  local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1

  if stringStart > 1 then
    contents = string.sub(value, 1, stringStart - 1)
  end

  contents = contents .. string.sub(value, stringFinish + 1, -1)

  return vimBenchmark("createNew()", function()
    return buffer:createNew(contents, rangeStart, 0)
  end)
end

function Delete.getKeys()
  return {
    {
      modifiers = {},
      key = 'delete'
    }
  }
end

return Delete
