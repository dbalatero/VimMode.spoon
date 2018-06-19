local module = {}

module.deepcopy = function(orig)
  local orig_type = type(orig)
  local copy

  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[module.deepcopy(orig_key)] = module.deepcopy(orig_value)
    end

    setmetatable(copy, module.deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end

  return copy
end

module.sendKeys = function(modifiers, key)
  hs.eventtap.keyStroke(modifiers or {}, key, 0)
end

return module
