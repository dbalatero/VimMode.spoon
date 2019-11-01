local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")

local Change = Delete:new{ name = 'change' }

-- Special case: "cw" and "cW" are treated like "ce" and "cE" if the cursor is
-- on a non-blank.  This is Vi-compatible, see |cpo-_| to change the behavior.
function Change.getModeForTransition()
  return "insert"
end

return Change
