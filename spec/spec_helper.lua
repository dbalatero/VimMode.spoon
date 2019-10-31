inspect = dofile("lib/utils/inspect.lua")

vimModeScriptPath = ""

vimLogger = dofile("lib/utils/log.lua")
-- conform to the Hammerspoon logging API as well
vimLogger.i = vimLogger.info
vimLogger.d = vimLogger.debug
vimLogger.e = vimLogger.error
vimLogger.v = vimLogger.trace
