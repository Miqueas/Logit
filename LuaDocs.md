# Usage

A very simple example.

```lua
local Logit, LogLevel = require("logit")()
local log = Logit:new("./", "MyApp")
log:start()

log(LogLevel.INFO, "application started")

-- your code...

log:finish()
```

Check out the [test file](test.lua) for a better example

## API

Most of Logit methods arguments are optionals and has its defaults values. They also has `string.format` built-in support, that's means, methods with `...` arguments uses that for string formatting.

```lua
--- @type LogLevel
--- @enum LogLevel
local LogLevel = { OTHER = 0, TRACE = 1, INFO  = 2, DEBUG = 3, WARN  = 4, ERROR = 5, FATAL = 6 }
```

```lua
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
```

```lua
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
```