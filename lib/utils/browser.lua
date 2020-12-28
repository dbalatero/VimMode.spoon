local browserUtils = {}

browserUtils.isFrontmostChrome = function()
  local name = hs.application.frontmostApplication():name()

  return name == "Google Chrome" or name == "Chromium"
end

browserUtils.isFrontmostSafari = function()
  local name = hs.application.frontmostApplication():name()

  return name == "Safari"
end

browserUtils.frontmostCurrentUrl = function()
  if browserUtils.isFrontmostChrome() then
    result, url = hs.osascript.applescript(
      'tell application "Google Chrome" to return URL of active tab of front window'
    )

    if result and url then
      return url
    end
  elseif browserUtils.isFrontmostSafari() then
    result, url = hs.osascript.applescript(
      'tell application "Safari" to return URL of current tab of window 1'
    )

    if result and url then
      return url
    end
  end

  return nil
end

return browserUtils
