package = "logit"
-- SemVer: 5.0.0
-- Revisión: 0
version = "5.0.0-0"
source  = {
  url = "git://github.com/Miqueas/Logit",
  tag = "v5.0.0"
}

description = {
  summary  = "Easy logging for Lua",
  detailed = "A dependency-free, cross-platform, simple and well designed logging library for Lua",
  homepage = "https://github.com/Miqueas/Logit",
  license  = "zlib"
}

dependencies = { "lua >= 5.1" }

build = {
  type = "builtin",
  modules = { logit = "logit.lua" }
}