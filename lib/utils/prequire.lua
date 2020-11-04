local function prequire(...)
  local status, lib = pcall(require, ...)
  if status then return lib end

  -- Library failed to load, so perhaps return `nil` or something?
  return nil
end

return prequire
