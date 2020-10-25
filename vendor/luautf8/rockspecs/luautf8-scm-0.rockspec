package = "luautf8"
version = "scm-0"

source = {
  url = "git://github.com/starwing/luautf8"
}

description = {
  summary = "A UTF-8 support module for Lua",
  detailed = [[
   This module adds UTF-8 support to Lua. It's compatible with Lua "string" module.
  ]],
  homepage = "http://github.com/starwing/luautf8",
  license = "MIT",
}

dependencies = {
  "lua >= 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["lua-utf8"]= "lutf8lib.c"
  }
}
