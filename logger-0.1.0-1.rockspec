package = "Logger"
version = "0.1.0"
source = {
  url = "git://github.com/M1que4s/Logger",
  tag = "v0.1.0"
}

description = {
  summary = "Logging made easy!",
  detailed = "A small and versatile library to create log files with Lua that you can easily integrate into your projects.",
  homepage = "https://github.com/M1que4s/Logger",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    Logger = "Logger.lua"
  }
}
