local ax = require("hs._asm.axuielement")

local registeredPids = {}

local function createApplicationWatcher(application, vim)
  local pid = application:pid()
  if registeredPids[pid] then return end

  local observer = ax.observer.new(application:pid())

  observer
    :callback(function() vim:exit() end)
    :addWatcher(ax.applicationElement(application), "AXFocusedUIElementChanged")
    :start()

  registeredPids[pid] = observer

  return observer
end

-- When someone focuses out of a field, we want to exit Vim mode if necessary.
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
