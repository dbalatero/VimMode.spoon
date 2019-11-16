local numberUtils = {}

function numberUtils.pushDigit(number, digit)
  number = number or 0
  if not digit then return number end

  return number * 10 + digit
end

return numberUtils
