--[[
  Author: Miqueas Martinez (https://github.com/Miqueas)
  Co-Author: Nelson "darltrash" López (https://github.com/darltrash)
  Date: 2020/09/12
  License: zlib (see it in the repository)
  Git Repository: https://github.com/Miqueas/Logit
]]

--- 0x1b: see the Wikipedia link above
local ESC = string.char(27)
--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc
os.is_win = package.config:sub(1, 1) == "\\"

--- Helper function to create color escape-codes. Read this for more info:
--- https://en.wikipedia.org/wiki/ANSI_escape_code.
--- One or more numbers/strings expected
--- @vararg number | string
--- @return string
local function e(...)
  return ESC .. "[" .. table.concat({ ... }, ";") .. "m"
end

--[[==== PRIVATE ====]]

--- A simple custom version of `assert()` with built-in
--- `string.format()` support
--- @generic Expr
--- @param exp Expr Expression to evaluate
--- @param msg string Error message to print
--- @vararg any Additional arguments to format for `msg`
--- @return Expr
local function err(exp, msg, ...)
  local msg = msg:format(...)

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

--- Return the path to the temp dir
--- @return string
function io.get_temp_dir()
  if os.is_win then
    -- Windows. Same as:
    --     os.getenv("TEMP")
    --     os.getenv("TMP")
    return os.getenv("UserProfile") .. "/AppData/Local/Temp"
  else
    -- Unix
    return os.getenv("TMPDIR") or "/tmp"
  end
end

--- Return `true` if `filename` exists
--- @return boolean
function io.exists(filename)
  local ok, _, code = os.rename(filename, filename)

  if code == 13 then
    -- Permission denied, but it exists
    return true
  end

  return ok ~= nil
end

--- Check if a directory exists in this path
--- @return boolean
function io.is_dir(path)
  if os.is_win then
    return io.exists(path .. "/")
  end

  return (io.open(path .. "/") == nil) and false or true
end

-- String "templates"
local FMT = {
  Filename = "%s_%s.log",
  Time = "%H:%M:%S",
  Out = {
    File = "%s [%s %s] %s@%s: %s\n",
    Console = e(2) .. "%s [" .. e(0, 1) .. "%s %s%s" .. e(0, 2) .. "] %s@%s:" .. e(0) .. " %s"
    --                                         ^~ This one is used for the log level color
  },
  Header = {
    File = "\n%s [%s]\n\n",
    Console = "\n" .. e(2) .. "%s [" .. e(0, 1) .. "%s" .. e(0, 2) .. "]" .. e(0) .. "\n"
  },
  Quit = {
    File = "%s [QUIT]: %s\n",
    Console = e(2) .. "%s [" .. e(0, 1) .. "%sQUIT" .. e(0, 2) .. "]: " .. e(0) .. "%s\n"
    --                                      ^~ This one is used for the log level color
  }
}

local ASSOC = {
  [0] = { name = "OTHER", color = 30 },
  [1] = { name = "TRACE", color = 32 },
  [2] = { name = "DEBUG", color = 36 },
  [3] = { name = "INFO.", color = 34 },
  [4] = { name = "WARN.", color = 33 },
  [5] = { name = "ERROR", color = 31 },
  [6] = { name = "FATAL", color = 35 },
}

--[[==== PUBLIC ====]]

--- @type Logit
--- @class Logit
--- @field path string
--- @field namespace string
--- @field filePrefix string
--- @field defaultLevel number
--- @field enableConsole boolean
--- @field OTHER number
--- @field TRACE number
--- @field DEBUG number
--- @field INFO number
--- @field WARN number
--- @field ERROR number
local Logit = {}
Logit.OTHER = 0
Logit.TRACE = 1
Logit.DEBUG = 2
Logit.INFO  = 3
Logit.WARN  = 4
Logit.ERROR = 5
Logit.FATAL = 6
Logit.path = io.get_temp_dir()
Logit.namespace = "Logit"
Logit.filePrefix = "%Y-%m-%d"
Logit.defaultLevel = Logit.OTHER
Logit.enableConsole = false

--- Creates a new instance of `Logit`
--- @param path string The path where logs will be saved (default is OS temp directory)
--- @param name string The log namespace (default is `Logit`)
--- @param level number The default log level (default is `Logit.OTHER` (0))
--- @param console boolean Enable/disable logging to console (default is `false`)
--- @param prefix string Log file prefix (default is the result of `os.date("%Y-%m-%d")`)
--- @return Logit
function Logit:new(path, name, level, console, prefix)
  path = opt_arg(1, path, "string", self.path)
  level = opt_arg(3, level, "number", self.defaultLevel)

  if level < 0 or level > 6 then
    err("invalid log level value '%s'", level)
  end

  local o = setmetatable({}, { __call = self.log, __index = self })
  o.namespace = opt_arg(2, name, "string", self.namespace)
  o.filePrefix = opt_arg(5, prefix, "string", self.filePrefix)
  o.defaultLevel = level
  o.enableConsole = opt_arg(4, console, "boolean", self.enableConsole)

  if io.is_dir(path) then
    o.path = path
  else
    err(nil, "'%s' isn't a valid path", path)
  end

  local date = os.date(o.filePrefix)
  local time = os.date(FMT.Time)
  local file = io.open(o.path .. '/' .. FMT.Filename:format(date, o.namespace), "a+")

  -- The gsub at the end removes color escape-codes
  file:write(FMT.Header.File:format(time, "GENERATED BY LOGIT, DO NOT EDIT"))
  file:close()

  if o.enableConsole then
    print(FMT.Header.Console:format(time, "LOGGING LIBRARY STARTED"))
  end

  return o
end

--- Makes a log
--- @param lvl number The log level
--- @param msg string The message to log
--- @param quitMsg string An optional message to write if `lvl > 4`
--- @return nil
function Logit:log(lvl, msg, quitMsg)
  check_arg(1, lvl, "number")
  msg = opt_arg(2, msg, "string", ASSOC[lvl].name)
  quitMsg = opt_arg(3, quitMsg, "string", msg)

  -- This prevents that 'Logit.lua' appears in the log message when
  -- `expect` is called
  local info = (debug.getinfo(2, "Sl").short_src:find("(logit.lua)"))
    and debug.getinfo(3, "Sl")
    or debug.getinfo(2, "Sl")

  local date = os.date(self.filePrefix)
  local time = os.date(FMT.Time)
  local file = io.open(self.path .. '/' .. FMT.Filename:format(date, self.namespace), "a+")

  file:write(FMT.Out.File:format(
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

  if lvl > 4 then
    file:write(FMT.Quit.File:format(time, quitMsg))
    file:close()

    if self.enableConsole then
      print(FMT.Quit.Console:format(time, e(ASSOC[lvl].color), quitMsg))
    end

    -- For Love2D compatibility
    if love then love.event.quit() end

    os.exit(1)
  else file:close() end
end

--- Like `assert`, but this automatically logs `msg`
--- @generic Expr
--- @param exp Expr The expression to evaluate
--- @param msg string The log message if fails
--- @return Expr
function Logit:expect(exp, msg)
  if not exp then
    self:log(Logit.ERROR, msg)
  else
    return exp
  end
end

--- Write a "header". Can be useful if you want to separate some logs
--- or create "breakpoints". This method supports `string.format`, so
--- you can pass a set of additional arguments to format `msg`
--- @param msg string The message to log
--- @return nil
function Logit:header(msg, ...)
  if type(msg) == "string" and #msg > 0 then
    msg = msg:format(...)

    local date = os.date(self.filePrefix)
    local time = os.date(FMT.Time)
    local file = io.open(self.path .. FMT.Filename:format(date, self.namespace), "a+")
    file:write(FMT.Header.File:format(time, msg))
    file:close()

    if self.enableConsole then print(FMT.Header.Console:format(time, msg)) end
  end
end

return Logit