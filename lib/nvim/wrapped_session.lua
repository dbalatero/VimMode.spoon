local ChildProcessStream = require('nvim.child_process_stream')
local Session = require('nvim.session')

local WrappedSession = {}

local function buildNotification(type, args)
  if type == "nvim_buf_changedtick_event" then
    return {
      type = "changedTick",
      rawType = type,
      buffer = args[1],
      changedTick = args[2]
    }
  elseif type == "nvim_buf_lines_event" then
    return {
      type = "changedLines",
      rawType = type,
      buffer = args[1],
      changedTick = args[2],
      -- zero-based
      firstLineIndex = args[3],
      -- end-exclusive
      lastLineIndex = args[4],
      linesChanged = args[5],
      hasChanges = #args[5] > 0,
      lineIndexRange = { args[3], args[4] - 1 },
      multipart = args[6]
    }
  end
end

function WrappedSession:new()
  local wrapper = {}

  setmetatable(wrapper, self)
  self.__index = self

  wrapper.session = Session.new(
    ChildProcessStream.spawn({
      '/usr/local/bin/nvim',
      '-u',
      'NONE',
      '--embed',
      '--headless'
    })
  )

  return wrapper
end

function WrappedSession:__gc()
  self.session:stop()
  self.session:close()
end

function WrappedSession:request(...)
  return self.session:request(...)
end

function WrappedSession:stop(...)
  return self.session:stop(...)
end

function WrappedSession:close(...)
  return self.session:close(...)
end

function WrappedSession:_nextMessage()
  local timeout = 0
  return self.session:next_message(timeout)
end

function WrappedSession:drainNotifications(onNotification)
  if not onNotification then
    error(
      "drainNotifications() requires an onNotification(notification) handler"
    )
  end

  local messageType, eventType, args
  local message = self:_nextMessage()

  while message do
    messageType = message[1]

    if messageType == "notification" then
      eventType = message[2]
      args = message[3]

      -- convert to a notification struct
      notification = buildNotification(eventType, args)
      onNotification(notification)
    end

    message = self:_nextMessage()
  end
end

return WrappedSession
