package = "logit"
version = "0.1.5-0"
source  = {
  url = "git://github.com/Miqueas/Logit",
  tag = "v0.1.5"
}

description = {
  summary  = "Easy logging for Lua and Nim",
  detailed = "Dependency-free, cross-platform and small logging library for Lua and Nim, with a simple and comfortable API",
  homepage = "https://github.com/Miqueas/Logit",
  license  = "zlib"
}

dependencies = { "lua >= 5.1" }

build = {
  type = "builtin",
  modules = { logit = "logit.lua" }
}