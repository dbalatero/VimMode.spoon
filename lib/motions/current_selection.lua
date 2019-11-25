local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local CurrentSelection = Motion:new{ name = 'current_selection' }

function CurrentSelection.getRange(_, buffer)
  local selection = buffer:getSelectionRange()

  return {
    start = selection.location,
    finish = selection:positionEnd(),
    mode = 'inclusive',
    direction = 'characterwise'
  }
end

function CurrentSelection.getMovements()
  return {}
end

return CurrentSelection
