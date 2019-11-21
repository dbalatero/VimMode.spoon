local function findFirst(list, fn)
  for _, item in ipairs(list) do
    if fn(item) then return item end
  end

  return nil
end

return findFirst
