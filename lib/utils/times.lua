local function times(n, fn)
  local i = 0

  while i < n do
    fn()
    i = i + 1
  end
end

return times
