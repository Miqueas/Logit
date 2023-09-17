# Usage

A very simple example:

```nim
import logit
from std/os import getCurrentDir

var log = initLogit(getCurrentDir(), "MyApp")
log.start()

log(INFO, "application started")

# Some code here...

log.finish()
```

Check out the [test file](test.nim) for a better example.

## API

```nim
type LogLevel* = enum OTHER, TRACE, INFO, DEBUG, WARN, ERROR, FATAL
```

The logging levels, from less to more important.

```nim
type Logit* = object
# Private
  file: File # Internal file used to write logs
  logsFolder: string # Path where logs are saved
# Public
  filePrefix*: TimeFormat # Log file name prefix
  namespace*: string # Logging namespace
  exitOnError*: bool # Enable/disable calling `quit` in case of `ERROR` or `FATAL`
  logToFile*: bool # Enable/disable logging to file
  logToConsole*: bool # Enable/disable logging to console
  defaultLogLevel*: LogLevel # Default logging level
```

The Logit object, which stores some required shared data. __Use `initLogit` instead of creating a new object manually.__

```nim
proc initLogit*(logsFolder = getTempDir(),
                namespace = "Logit",
                defaultLogLevel = OTHER,
                logToFile = true,
                logToConsole = false,
                exitOnError = false,
                filePrefix = initTimeFormat("YYYY-MM-dd")
               ): Logit {.raises: [IOError, ValueError].}
```

Creates a new Logit object. Raises an error if `logsFolder` isn't a valid path or doesn't exists.

```nim
proc start*(self: var Logit) {.raises: [IOError, ValueError].}
```

Prepares Logit for logging. Call this proc before start logging and only if you have set `logToFile` to `true` and/or if you have a handmade `Logit` object. Also, if you have a handmade Logit object, don't call this proc if you don't have been set `logsFolder` before.

```nim
template log*(self: Logit, level: LogLevel, logMessage = $level)
```

Makes a log. This is the most important template of Logit, you'll use it every time you'll make a log and the following templates are just "shortcuts".

```nim
template `()`*(self: Logit, level: LogLevel, logMessage = $level) {.inline.}
```

Custom "call" operator, that allows you to "call" the Logit object as a function and make a log.

```nim
template log*(self: Logit, logMessage = "") {.inline.}
```
Same as the other `log` template, but uses `defaultLogLevel` as log level.

```nim
template `()`*(self: Logit, logMessage = "") {.inline.}
```

Same as the other "call" operator, but uses `defaultLogLevel` as log level.

```nim
template other*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(OTHER, logMessage)`.

```nim
template trace*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(TRACE, logMessage)`.

```nim
template info*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(INFO, logMessage)`.

```nim
template debug*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(DEBUG, logMessage)`.

```nim
template warn*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(WARN, logMessage)`.

```nim
template error*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(ERROR, logMessage)`.

```nim
template fatal*(self: Logit, logMessage = "") {.inline.}
```

Same as `self.log(FATAL, logMessage)`.

```nim
proc header*(self: Logit, msg: string)
```

Makes a "header", which in the context of Logit is just a line separated of the rest of the logs, used for general purpose.

```nim
proc finish*(self: var Logit) {.inline.}
```

Ends the logging session. Use this when you'll not use Logit anymore. Same rules as in `start` applies here, since this proc just basically closes the internal file.

```nim
proc logsFolder*(self: Logit): string {.inline.}
```

Getter for `logsFolder`.

```nim
proc `logsFolder=`*(self: var Logit, newLogsFolder: string) {.raises: [IOError, ValueError].}
```

Setter for `logsFolder`. Raises an error if `newLogsFolder` isn't a valid path or doesn't exists.