local ax = dofile(vimModeScriptPath .. "lib/axuielement.lua")

local registeredPids = {}

local function createApplicationWatcher(application, vim)
  if not application then return nil end

  local pid = application:pid()
  local observer

  local creator = function ()
    if registeredPids[pid] then return end

    observer = ax.observer.new(application:pid())

    observer
      :callback(function() vim:exit() end)
      :addWatcher(
        ax.applicationElement(application),
        "AXFocusedUIElementChanged"
      )
      :start()

    registeredPids[pid] = observer
  end

  local status, error = pcall(creator)

  if not status then
    registeredPids[pid] = nil

    vimLogger.d(
      "Could not start watcher for PID: " .. pid ..
        " and name: " .. application:name()
    )

    vimLogger.d("Error: " .. hs.inspect.inspect(error))
  end

  return observer
end

-- When someone focuses out of a field, we want to exit Vim mode.
local function createFocusWatcher(vim)
  createApplicationWatcher(hs.application.frontmostApplication(), vim)

  local watcher = hs.application.watcher.new(function(_, eventType, application)
    if eventType == hs.application.watcher.activated then
      createApplicationWatcher(application, vim)
    end
  end)

  watcher:start()

  return watcher
end

return createFocusWatcher
