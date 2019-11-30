local numberUtils = dofile(vimModeScriptPath .. "lib/utils/number_utils.lua")

local CommandState = {}

function CommandState:new()
  local state = {
    motion = nil,
    motionTimes = nil,
    operator = nil,
    operatorTimes = nil,
    pendingInput = nil
  }

  setmetatable(state, self)
  self.__index = self

  return state
end

function CommandState:getRepeatTimes()
  local operatorTimes = self:getCount('operator') or 1
  local motionTimes = self:getCount('motion') or 1

  return operatorTimes * motionTimes
end

function CommandState:getCount(type)
  return self[type .. "Times"]
end

function CommandState:getPendingInput()
  return self.pendingInput
end

function CommandState:setPendingInput(value)
  self.pendingInput = value

  return self
end

function CommandState:pushCountDigit(type, digit)
  local key = type .. "Times"
  self[key] = numberUtils.pushDigit(self[key], digit)
end

return CommandState
