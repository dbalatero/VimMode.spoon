function vimBenchmark(name, fn)
  local start = hs.timer.absoluteTime()
  result = fn()
  local finish = hs.timer.absoluteTime()

  time = (finish - start) / 100000

  vimLogger.i(name .. " took " .. time .. "ms")

  return result
end
