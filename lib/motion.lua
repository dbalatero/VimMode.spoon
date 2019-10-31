local Motion = {}

function Motion:new()
  local motion = {}

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

return Motion
