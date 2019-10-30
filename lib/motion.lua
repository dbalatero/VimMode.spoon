local Motion = {}

function Motion:new()
  local motion = {}

  setmetatable(motion, self)
  self.__index = self

  return motion
end

function Motion:getMovements(buffer)
  error("Please implement getMovements()")
end

return Motion
