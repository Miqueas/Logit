--[[
  Author: Miqueas Martinez (https://github.com/Miqueas)
  Co-Author: Nelson "darltrash" López (https://github.com/darltrash)
  Date: 2020/09/12
  License: zlib (see it in the repository)
  Git Repository: https://github.com/Miqueas/Logit
]]

--- 0x1b: see the Wikipedia link below in `isWin`
local ESC = string.char(27)

--- `true` if OS is Windows, `false` otherwise.
--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc:
--- @type boolean
local isWindows = os.getenv("OS") ~= nil

--- Helper function to create color escape-codes. Read this for more info:
--- https://en.wikipedia.org/wiki/ANSI_escape_code. One or more numbers/strings expected
--- @vararg number | string
--- @return string
local function e(...) return ESC .. "[" .. table.concat({ ... }, ";") .. "m" end

--- A simple custom version of `assert()` with built-in `string.format()` support
--- @generic Expr
--- @param exp Expr Expression to evaluate
--- @param msg string Error message to print
--- @vararg any Additional arguments to format for `msg`
--- @return Expr
local function test(exp, msg, ...)
  msg = msg:format(...)

  if not exp then
    return error(msg)
  end

  return exp
end

--- Argument type checking function
--- @generic Type
--- @param argn number The argument position in function
--- @param argv any The argument to check
--- @param expected Type The type expected (`string`)
local function requiredArgument(argn, argv, expected)
  local argType = type(argv)
  local messageTemplate = "bad argument #%s, `%s` expected, got `%s`"

  if argType ~= expected then
    error(messageTemplate:format(argn, expected, argType))
  end
end

--- Same as `check_arg()`, except that this don't throw an error if the argument is `nil`
--- @generic Type
--- @param argn number The argument position in function
--- @param argv? any The argument to check
--- @param expected Type The type expected (`string`)
--- @return any default If `argv` is `nil`, `default` is returned
local function optionalArgument(argn, argv, expected, default)
  local argType = type(argv)
  local messageTemplate = "bad argument #%s, `%s` or `nil` expected, got `%s`"

  if argType ~= expected then
    if argType == "nil" then
      return default
    else
      error(messageTemplate:format(argn, expected, argType))
    end
  end

  return argv
end

--- Path to the temp directory.
--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc
--- @type string
local tempFolder = isWindows and os.getenv("UserProfile") .. "/AppData/Local/Temp" or "/tmp"

--- Return `true` if `filename` exists.
--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc
--- @param path string The path to the file/folder
--- @return boolean
local function pathExists(path)
  local ok, _, code = os.rename(path, path)

  if code == 13 then
    -- Permission denied, but it exists
    return true
  end

  return ok ~= nil
end

--- Check if a directory exists in this path.
--- From my Gist: https://gist.github.com/Miqueas/53cf4344575ccedbf264010442a21dcc
--- @return boolean
local function isDirectory(path)
  if isWindows then
    return pathExists(path .. "/")
  end

  return (io.open(path .. "/") == nil) and false or true
end

--- @type LogLevel
--- @enum LogLevel
local LogLevel = { OTHER = 0, TRACE = 1, INFO  = 2, DEBUG = 3, WARN  = 4, ERROR = 5, FATAL = 6 }

--- @type Logit
--- @class Logit
--- @field logsFolder string
--- @field exitOnError boolean
--- @field namespace string
--- @field filePrefix string
--- @field defaultLogLevel number
--- @field logToConsole boolean
local Logit = {
  logsFolder = tempFolder,
  filePrefix = "%Y-%m-%d",
  namespace = "Logit",
  exitOnError = false,
  logToFile = true,
  logToConsole = false,
  defaultLogLevel = LogLevel.OTHER,
}

-- String templates
local fmt = {
  fileName = "%s_%s.log",
  time = "%H:%M:%S",
  fileLine = "%s [%s %s] %s:%s %s\n",
  consoleLine = e(2) .. "%s [" .. e(0, 1) .. "%s %s%s" .. e(0, 2) .. "] %s:%s" .. e(0) .. " %s",
  --                                             ^~ This one is used for the color
  fileHeader = "\n%s [%s]\n\n",
  consoleHeader = "\n" .. e(2) .. "%s [" .. e(0, 1) .. "%s" .. e(0, 2) .. "]" .. e(0) .. "\n",
  fileExit = "%s [EXIT]\n",
  consoleExit = e(2) .. "%s [" .. e(0, 1) .. "%sEXIT" .. e(0, 2) .. "]" .. e(0) .. "\n"
  --                                          ^~ This one is used for the color
}

-- Used to color in console
local assoc = {
  [LogLevel.OTHER] = { name = "OTHER", color = 30 },
  [LogLevel.TRACE] = { name = "TRACE", color = 32 },
  [LogLevel.INFO] = { name = "INFO.", color = 34 },
  [LogLevel.DEBUG] = { name = "DEBUG", color = 36 },
  [LogLevel.WARN] = { name = "WARN.", color = 33 },
  [LogLevel.ERROR] = { name = "ERROR", color = 31 },
  [LogLevel.FATAL] = { name = "FATAL", color = 35 },
}

--- Creates a new `Logit` instance
--- @param logsFolder? string The path where logs will be saved (__default__: OS temp directory)
--- @param namespace? string The log namespace (__default__: `"Logit"`)
--- @param defaultLogLevel? number The default log level (__default__: `LogLevel.OTHER` (`0`))
--- @param logToFile? boolean Enable/disable logging to file (__default__: `true`)
--- @param logToConsole? boolean Enable/disable logging to console (__default__: `false`)
--- @param exitOnError? boolean Enable/disable automatically quit application (__default__: `false`)
--- @param filePrefix? string Log file prefix, this is used with `os.date` (__default__: `"%Y-%m-%d"`)
--- @return Logit
function Logit:new(logsFolder,
                   namespace,
                   defaultLogLevel,
                   logToFile,
                   logToConsole,
                   exitOnError,
                   filePrefix)
  logsFolder = optionalArgument(1, logsFolder, "string", self.logsFolder)
  defaultLogLevel = optionalArgument(3, defaultLogLevel, "number", self.defaultLogLevel)

  test(not (defaultLogLevel < LogLevel.OTHER or defaultLogLevel > LogLevel.FATAL), "invalid log level '%s'", defaultLogLevel)
  test(isDirectory(logsFolder), "'%s' isn't a valid path or doesn't exists", logsFolder)

  local o = setmetatable({}, { __call = self.log, __index = self })
  o.logsFolder = logsFolder
  o.filePrefix = optionalArgument(7, filePrefix, "string", self.filePrefix)
  o.namespace = optionalArgument(2, namespace, "string", self.namespace)
  o.logToFile = optionalArgument(4, logToFile, "boolean", self.logToFile)
  o.logToConsole = optionalArgument(5, logToConsole, "boolean", self.logToConsole)
  o.exitOnError = optionalArgument(6, exitOnError, "boolean", self.exitOnError)
  o.defaultLogLevel = defaultLogLevel

  return o
end

function Logit:start()
  if self.logToFile then
    local date = os.date(self.filePrefix)
    local filename = fmt.fileName:format(date, self.namespace)

    self.file = io.open(self.logsFolder .. '/' .. filename, "a+")
    test(self.file, "can't open/write file '%s'", filename)
  end
end

--- Makes a log
--- @param level LogLevel The log level
--- @param message string The message to log
function Logit:log(level, message, ...)
  level = optionalArgument(1, level, "number", self.defaultLogLevel)
  message = optionalArgument(2, message, "string", assoc[level].name):format(...)

  -- This prevents that 'Logit.lua' appears in the log message when
  -- `expect` is called
  local info = (debug.getinfo(2, "Sl").short_src:find("(logit.lua)"))
    and debug.getinfo(3, "Sl")
    or debug.getinfo(2, "Sl")

  local time = os.date(fmt.time)

  if self.logToFile then
    self.file:write(fmt.fileLine:format(time, self.namespace, assoc[level].name, info.short_src, info.currentline, message))
  end

  if self.logToConsole then
    print(fmt.consoleLine:format(time, self.namespace, e(assoc[level].color), assoc[level].name, info.short_src, info.currentline, message))
  end

  if self.exitOnError and level > LogLevel.WARN then
    if self.logToFile then
      self.file:write(fmt.fileExit:format(time))
      self.file:close()
    end

    if self.logToConsole then
      print(fmt.Quit.Console:format(time, e(assoc[level].color)))
    end

    -- For Love2D compatibility
    if love then love.event.quit() end

    os.exit(1)
  end
end

function Logit:other(message, ...) self:log(LogLevel.OTHER, message, ...) end
function Logit:trace(message, ...) self:log(LogLevel.TRACE, message, ...) end
function Logit:info(message, ...) self:log(LogLevel.INFO, message, ...) end
function Logit:debug(message, ...) self:log(LogLevel.DEBUG, message, ...) end
function Logit:warn(message, ...) self:log(LogLevel.WARN, message, ...) end
function Logit:error(message, ...) self:log(LogLevel.ERROR, message, ...) end
function Logit:fatal(message, ...) self:log(LogLevel.FATAL, message, ...) end

--- Write a "header". Can be useful if you want to separate some logs
--- or create "breakpoints". This method supports `string.format`, so
--- you can pass a set of additional arguments to format `msg`
--- @param msg string The message to log
--- @return nil
function Logit:header(msg, ...)
  requiredArgument(1, msg, "string")
  msg = msg:format(...)

  local time = os.date(fmt.time)

  if self.logToFile then self.file:write(fmt.fileHeader:format(time, msg)) end
  if self.logToConsole then print(fmt.consoleHeader:format(time, msg)) end
end

--- Closes the internal file. Call this if you're sure you'll
--- not need to use a `Logit` instance anymore
--- @return nil
function Logit:finish() self.file:close() end

return function ()
  return Logit, LogLevel
end