local axUtils = dofile(vimModeScriptPath .. "lib/utils/ax.lua")

local function createHotPatcher()
  -- Always patch the currently open application.
  axUtils.patchCurrentApplication()

  return hs.application.watcher.new(function(_, eventType)
    if eventType == hs.application.watcher.activated then
      axUtils.patchCurrentApplication()
    end
  end)
end

return createHotPatcher
