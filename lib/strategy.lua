local Strategy = {}

function Strategy:new(vim)
  local strategy = {
    vim = vim,
  }

  setmetatable(strategy, self)
  self.__index = self

  return strategy
end

function Strategy.fire(_)
  error("Implement fire()")
end

function Strategy.isValid(_)
  return true
end


return Strategy
