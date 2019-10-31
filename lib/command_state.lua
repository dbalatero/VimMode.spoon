local CommandState = {}

function CommandState:new()
  local state = {
    motion = nil,
    motionTimes = 1,
    operator = nil,
    operatorTimes = 1
  }

  setmetatable(state, self)
  self.__index = self

  return state
end

return CommandState
