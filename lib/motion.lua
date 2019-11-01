local Motion = {}

function Motion:new(fields)
  local motion = fields or {}

  setmetatable(motion, self)
  self.__index = self

  return motion
end

function Motion:getMovements()
  error("Please implement getMovements()")
end

function Motion:getRange(buffer)
  error("Please implement getRange()")
end

function Motion.getModeForTransition()
  return "normal"
end

return Motion
