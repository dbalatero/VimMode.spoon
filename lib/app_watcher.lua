local AppWatcher = {}

local function debugEventType(eventType)
  if eventType == hs.application.watcher.activated then
    return "activated"
  elseif eventType == hs.application.watcher.deactivated then
    return "deactivated"
  elseif eventType == hs.application.watcher.hidden then
    return "hidden"
  elseif eventType == hs.application.watcher.launched then
    return "launched"
  elseif eventType == hs.application.watcher.launching then
    return "launching"
  elseif eventType == hs.application.watcher.terminated then
    return "terminated"
  elseif eventType == hs.application.watcher.unhidden then
    return "unhidden"
  else
    return "unknown event: " .. eventType
  end
end

function AppWatcher:new(vim)
  local watcher = {
    -- These are the default apps that we automatically turn off Vim mode
    -- in when they become focused in the OS.
    disabled = {
      MacVim = true,
      iTerm = true,
      iTerm2 = true,
      Terminal = true
    },
    vim = vim,
    watcher = nil
  }

  setmetatable(watcher, self)
  self.__index = self

  watcher:createWatcher()

  return watcher
end

function AppWatcher:disableVim()
  self.vim:exit()
  self.vim:disable()
end

function AppWatcher:enableVim()
  self.vim:enable()
end

function AppWatcher:start()
  self.watcher:start()

  return self
end

function AppWatcher:stop()
  self.watcher:stop()

  return self
end

function AppWatcher:disableApp(name)
  self.disabled[name] = true

  -- disable it proactively if needed
  local currentApplication = hs.application.frontmostApplication()

  if currentApplication and currentApplication:name() == name then
    self:disableVim()
  end

  return self
end

function AppWatcher:createWatcher()
  -- build the watcher
  self.watcher =
    hs.application.watcher.new(function(applicationName, eventType, application)
      local disabled = self.disabled[applicationName]

      if eventType == hs.application.watcher.activated then
        if disabled then
          self:disableVim()
        else
          self:enableVim()
        end
      end
    end)

  -- If we are currently in this disabled application, exit vim mode
  -- and disable
  local currentApplication = hs.application.frontmostApplication()

  if self.disabled[currentApplication:name()] then
    self:disableVim()
  end
end

return AppWatcher
