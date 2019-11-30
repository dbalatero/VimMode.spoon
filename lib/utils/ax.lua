local axUtils = {}

axUtils.isTextField = function(element)
  if not element then return false end

  local role = element:attributeValue("AXRole")

  return role == "AXTextField" or role == "AXTextArea"
end

return axUtils
