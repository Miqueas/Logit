--[[
  Author: Miqueas Martinez (https://github.com/Miqueas)
  Co-Author: Nelson "darltrash" López (https://github.com/darltrash)
  Date: 2020/09/12
  License: zlib (see it in the repository)
  Git Repository: https://github.com/Miqueas/Logit
]]

-- 0x1b: see the Wikipedia link above
local ESC = string.char(27)

--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc:
--- `true` if OS is Windows, `false` otherwise
--- @type boolean
local isWin = package.config:sub(1, 1) == "\\"

--- Helper function to create color escape-codes. Read this for more info:
--- https://en.wikipedia.org/wiki/ANSI_escape_code.
--- One or more numbers/strings expected
--- @vararg number | string
--- @return string
local function e(...)
  return ESC .. "[" .. table.concat({ ... }, ";") .. "m"
end

--[[======== PRIVATE ========]]

--- A simple custom version of `assert()` with built-in
--- `string.format()` support
--- @generic Expr
--- @param exp Expr Expression to evaluate
--- @param msg string Error message to print
--- @vararg any Additional arguments to format for `msg`
--- @return Expr
local function err(exp, msg, ...)
  msg = msg:format(...)

  if not exp then
    return error(msg)
  end

  return exp
end

--- Argument type checking function
--- @generic Any
--- @generic Type
--- @param argn number The argument position in function
--- @param argv Any The argument to check
--- @param expected Type The type expected (`string`)
--- @return nil
local function check_arg(argn, argv, expected)
  local argt = type(argv)
  local msgt = "bad argument #%s, `%s` expected, got `%s`"

  if argt ~= expected then
    error(msgt:format(argn, expected, argt))
  end
end

--- Same as `check_arg()`, except that this don't throw
--- and error if the argument is `nil`
--- @generic Any
--- @generic Type
--- @param argn number The argument position in function
--- @param argv Any The argument to check
--- @param expected Type The type expected (`string`)
--- @return Any
local function opt_arg(argn, argv, expected, default)
  local argt = type(argv)
  local msgt = "bad argument #%s, `%s` or `nil` expected, got `%s`"

  if argt ~= expected then
    if argt == "nil" then
      return default
    else
      error(msgt:format(argn, expected, argt))
    end
  end

  return argv
end

--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc:
--- Path to the temp directory
--- @type string
local tempDir = isWin and os.getenv("UserProfile") .. "/AppData/Local/Temp" or "/tmp"

--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc:
--- Return `true` if `filename` exists
--- @param path string The path to the file
--- @return boolean
local function pathExists(path)
  local ok, _, code = os.rename(path, path)

  if code == 13 then
    -- Permission denied, but it exists
    return true
  end

  return ok ~= nil
end

--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc:
--- Check if a directory exists in this path
--- @return boolean
local function isDir(path)
  if isWin then
    return pathExists(path .. "/")
  end

  return (io.open(path .. "/") == nil) and false or true
end

-- String "templates"
local FMT = {
  Filename = "%s_%s.log",
  Time = "%H:%M:%S",
  Out = {
    File = "%s [%s %s] %s:%s %s\n",
    Console = e(2) .. "%s [" .. e(0, 1) .. "%s %s%s" .. e(0, 2) .. "] %s:%s" .. e(0) .. " %s"
    --                                         ^~ This one is used for the log level color
  },
  Header = {
    File = "\n%s [%s]\n\n",
    Console = "\n" .. e(2) .. "%s [" .. e(0, 1) .. "%s" .. e(0, 2) .. "]" .. e(0) .. "\n"
  },
  Quit = {
    File = "%s [EXIT]\n",
    Console = e(2) .. "%s [" .. e(0, 1) .. "%sEXIT" .. e(0, 2) .. "]" .. e(0) .. "\n"
    --                                      ^~ This one is used for the log level color
  }
}

-- Used to color in console
local ASSOC = {
  [0] = { name = "OTHER", color = 30 },
  [1] = { name = "TRACE", color = 32 },
  [2] = { name = "INFO.", color = 34 },
  [3] = { name = "DEBUG", color = 36 },
  [4] = { name = "WARN.", color = 33 },
  [5] = { name = "ERROR", color = 31 },
  [6] = { name = "FATAL", color = 35 },
}

-- Internal file used for write logs
local FILE

--[[======== PUBLIC ========]]

--- @type Logit
--- @class Logit
--- @field OTHER number
--- @field TRACE number
--- @field INFO number
--- @field DEBUG number
--- @field WARN number
--- @field ERROR number
--- @field FATAL number
--- @field path string
--- @field autoSTOP boolean
--- @field namespace string
--- @field filePrefix string
--- @field defaultLevel number
--- @field enableConsole boolean
local Logit = {}

Logit.OTHER = 0
Logit.TRACE = 1
Logit.INFO  = 2
Logit.DEBUG = 3
Logit.WARN  = 4
Logit.ERROR = 5
Logit.FATAL = 6

Logit.path = tempDir
Logit.autoSTOP = true
Logit.namespace = "Logit"
Logit.filePrefix = "%Y-%m-%d"
Logit.defaultLevel = Logit.OTHER
Logit.enableConsole = false

--- Creates a new instance of `Logit`
--- @param path string The path where logs will be saved
--- @param name string The log namespace (default is `Logit`)
--- @param lvl number The default log level (default is `Logit.OTHER` (0))
--- @param console boolean Enable/disable logging to console (default is `false`)
--- @param STOP boolean Enable/disable automatically quit application (default is `true`)
--- @param prefix string Log file prefix (default is the result of `os.date("%Y-%m-%d")`)
--- @return Logit
function Logit:new(path, name, lvl, console, STOP, prefix)
  path = opt_arg(1, path, "string", self.path)
  lvl = opt_arg(3, lvl, "number", self.defaultLevel)

  err(not (lvl < 0 or lvl > 6), "invalid log level '%s'", lvl)
  err(isDir(path), "'%s' isn't a valid path or doesn't exists", path)

  local o = setmetatable({}, { __call = self.log, __index = self })
  o.path = path
  o.autoSTOP = opt_arg(5, STOP, "boolean", self.autoSTOP)
  o.namespace = opt_arg(2, name, "string", self.namespace)
  o.filePrefix = opt_arg(6, prefix, "string", self.filePrefix)
  o.defaultLevel = lvl
  o.enableConsole = opt_arg(4, console, "boolean", self.enableConsole)

  local date = os.date(o.filePrefix)
  local filename = FMT.Filename:format(date, o.namespace)

  FILE = io.open(o.path .. '/' .. filename, "a+")
  err(FILE, "can't open/write file '%s'", filename)

  return o
end

--- Makes a log
--- @param lvl number The log level
--- @param msg string The message to log
--- @return nil
function Logit:log(lvl, msg, ...)
  lvl = opt_arg(1, lvl, "number", self.defaultLevel)
  msg = opt_arg(2, msg, "string", ASSOC[lvl].name):format(...)

  -- This prevents that 'Logit.lua' appears in the log message when
  -- `expect` is called
  local info = (debug.getinfo(2, "Sl").short_src:find("(logit.lua)"))
    and debug.getinfo(3, "Sl")
    or debug.getinfo(2, "Sl")

  local time = os.date(FMT.Time)

  FILE:write(FMT.Out.File:format(
    time,
    self.namespace,
    ASSOC[lvl].name,
    info.short_src,
    info.currentline,
    msg
  ))

  if self.enableConsole then
    print(FMT.Out.Console:format(
      time,
      self.namespace,
      e(ASSOC[lvl].color),
      ASSOC[lvl].name,
      info.short_src,
      info.currentline,
      msg
    ))
  end

  if lvl > 4 and self.autoSTOP then
    FILE:write(FMT.Quit.File:format(time))
    FILE:close()

    if self.enableConsole then
      print(FMT.Quit.Console:format(time, e(ASSOC[lvl].color)))
    end

    -- For Love2D compatibility
    if love then love.event.quit() end

    os.exit(1)
  end
end

--- Like `assert`, but this automatically logs `msg`
--- @generic Expr
--- @param exp Expr The expression to evaluate
--- @param msg string The log message if fails
--- @return Expr
function Logit:expect(exp, msg, lvl, ...)
  msg = opt_arg(2, msg, "string", "expected condition failed")
  lvl = opt_arg(3, lvl, "number", Logit.ERROR)

  if not exp then
    self:log(lvl, msg, ...)
  end

  return exp
end

--- Write a "header". Can be useful if you want to separate some logs
--- or create "breakpoints". This method supports `string.format`, so
--- you can pass a set of additional arguments to format `msg`
--- @param msg string The message to log
--- @return nil
function Logit:header(msg, ...)
  check_arg(1, msg, "string")
  msg = msg:format(...)

  local time = os.date(FMT.Time)
  FILE:write(FMT.Header.File:format(time, msg))

  if self.enableConsole then
    print(FMT.Header.Console:format(time, msg))
  end
end

--- Closes the internal file. Call this if you're sure you'll
--- not need to use a `Logit` instance anymore
--- @return nil
function Logit:done()
  FILE:close()
end

return Logit