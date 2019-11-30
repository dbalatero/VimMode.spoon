local AppWatcher = {}

function AppWatcher:new(vim)
  local watcher = {
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
  vimLogger.i("AppWatcher is disabling Vim")
  self.vim:exit()
  self.vim:disable()
end

function AppWatcher:enableVim()
  vimLogger.i("AppWatcher is enabling Vim")
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

  if currentApplication:name() == name then
    self:disableVim()
  end

  return self
end

function AppWatcher:createWatcher()
  -- build the watcher
  self.watcher =
    hs.application.watcher.new(function(applicationName, eventType)
      -- App is not disabled, so we can ignore this
      if not self.disabled[applicationName] then return end

      if eventType == hs.application.watcher.activated then
        self:disableVim()
      elseif eventType == hs.application.watcher.deactivated then
        self:enableVim()
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
