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

## API Reference

### Types

#### `LogLevel`

The different levels of logging.

**Implementation**

```nim
LogLevel* = enum OTHER, TRACE, INFO, DEBUG, WARN, ERROR, FATAL
```

#### `Logit`

Object that holds shared data for loggin, like the `namespace`, the log `file`, and many more.

**Implementation**

```nim
Logit* = object
  # Private
  file: File # Internal file used to write logs
  logsDir: string # Path where logs are saved
  # Public
  namespace*: string # Logging namespace
  logToFile*: bool # Enable/disable logging to file
  filePrefix*: TimeFormat # Log file name prefix
  exitOnError*: bool # Enable/disable calling `quit` in case of `ERROR` or `FATAL`
  logToConsole*: bool # Enable/disable logging to console
  defaultLogLevel*: LogLevel # Default logging level
```

### Procs

#### `$`

Converts the given `lvl` into a `string`.

**Implementation**

```nim
proc `$`*(lvl: LogLevel): string =
  return case lvl:
    of OTHER: "OTHER"
    of TRACE: "TRACE"
    of INFO: "INFO."
    of DEBUG: "DEBUG"
    of WARN: "WARN."
    of ERROR: "ERROR"
    of FATAL: "FATAL"
```

#### `initLogit`

Creates a new `Logit` object using the given parameters. All parameters are optional because they all have default values.

**Implementation**

```nim
proc initLogit*(
  logsDir = getTempDir(),
  namespace = "Logit",
  logToFile = true,
  filePrefix = initTimeFormat("YYYY-MM-dd"),
  exitOnError = false,
  logToConsole = false,
  defaultLogLevel = OTHER,
): Logit {.raises: [IOError].} =
  if not dirExists(logsDir):
    raise newException(IOError, fmt"`{logsDir}` isn't a valid path or doesn't exists")

  return Logit(
    logsDir: logsDir,
    namespace: namespace,
    logToFile: logToFile,
    filePrefix: filePrefix,
    exitOnError: exitOnError,
    logToConsole: logToConsole,
    defaultLogLevel: defaultLogLevel
  )
```

#### `start`

Prepares this `Logit` instance by creating and opening the log file. You only need to call this proc if you need to save your logs in files (that is, when `logToFile` is `true`), and do so before starting to log anything. When `logToFile` is `false`, this is a no-op.

**Implementation**

```nim
proc start*(self: var Logit) {.raises: [IOError, ValueError].} =
  if self.logToFile:
    let
      date = now().format(self.filePrefix)
      filename = fmt.fileName.format(date, self.namespace)

    try:
      self.file = open(self.logsDir / filename, fmAppend)
    except:
      raise newException(IOError, fmt"can't open/write file {filename}")
```

#### `header`

Writes a "header", which is simply an isolated line with a different formatting. Check out [test.nim](test.nim) for a better example.

**Implementation**

```nim
proc header*(self: Logit, message: string) =
  let time = now().format(fmt.time)
  if self.logToFile: self.file.write(fmt.fileHeader.format(time, message))
  if self.logToConsole: echo fmt.consoleHeader.format(time, message)
```

#### `finish`

Closes the internal `file`, which effectively means that, if you have `logToFile` set to `true`, this `Logit` instance is no longer suitable for logging and shouldn't be used anymore.

**Implementation**

```nim
proc finish*(self: var Logit) {.inline.} = self.file.close()
```

#### `logsDir`

Getter for `logsDir`.

**Implementation**

```nim
proc logsDir*(self: Logit): string {.inline.} = self.logsDir
```

#### `logsDir=`

Setter for `logsDir`.

**Implementation**

```nim
proc `logsDir=`*(self: var Logit, newLogsDir: string) {.raises: [IOError, ValueError].} =
  if not dirExists(newLogsDir):
    raise newException(IOError, fmt"`{newLogsDir}` isn't a valid path or doesn't exists")

  self.logsDir = newLogsDir
```

### Templates

#### `log`

The main API you'll use in this library by performing a log with the given `level` and `message`. `autoNewLine` controls whether the log should automatically add a new line character at the end of each log or not. `message` is optional and defaults to just the log `level` (for instance, when level is `INFO` and no `message` is provided, it'll default to just the `"INFO"` string).

**Implementation**

```nim
template log*(self: Logit, level: LogLevel, message = $level, autoNewLine = true) =
  let
    time = now().format(fmt.time)
    info = instantiationInfo(0)

  if self.logToFile:
    let msg = fmt.fileLine.format(time, self.namespace, $level, info.filename, info.line, message)

    if autoNewLine: self.file.write(msg)
    else: self.file.write(msg.substr(0, msg.len - 2))

  if self.logToConsole:
    let msg = fmt.consoleLine.format(time, self.namespace, e(assoc[level]), $level, info.filename, info.line, message)

    if autoNewLine: echo msg
    else:
      stdout.write(msg)
      stdout.flushFile()

  if self.exitOnError and ord(level) > ord(WARN):
    if self.logToFile:
      self.file.write(fmt.fileExit.format(time))
      self.file.close()

    if self.logToConsole:
      quit(fmt.consoleExit.format(time, e(assoc[level])), QuitFailure)

    quit(QuitFailure)
```

#### `()`

Allows `Logit` to "call itself", executing `log` underneat. This is actually showcase in the example at the start of this document. This an `{.inline.}` template.

**Implementation**

```nim
template `()`*(self: Logit, level: LogLevel, message = $level, autoNewLine = true) =
  self.log(level, message, autoNewLine)
```

#### `log`

Alias/override of `log` without the `level` argument, replacing it with `defaultLogLevel`. This an `{.inline.}` template.

**Implementation**

```nim
template log*(self: Logit, message = "", autoNewLine = true) =
  self.log(self.defaultLogLevel, message, autoNewLine)
```

#### `()`

Alias/override of `()` without the `level` argument. This an `{.inline.}` template.

**Implementation**

```nim
template `()`*(self: Logit, message = "", autoNewLine = true) =
  self.log(message, autoNewLine)
```

#### `other`

Alias for `self.log(OTHER, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template other*(self: Logit, message = "", autoNewLine = true) =
  self.log(OTHER, message, autoNewLine)
```

#### `trace`

Alias for `self.log(TRACE, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template trace*(self: Logit, message = "", autoNewLine = true) =
  self.log(TRACE, message, autoNewLine)
```

#### `info`

Alias for `self.log(INFO, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template info*(self: Logit, message = "", autoNewLine = true) =
  self.log(INFO, message, autoNewLine)
```

#### `debug`

Alias for `self.log(DEBUG, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template debug*(self: Logit, message = "", autoNewLine = true) =
  self.log(DEBUG, message, autoNewLine)
```

#### `warn`

Alias for `self.log(WARN, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template warn*(self: Logit, message = "", autoNewLine = true) =
  self.log(WARN, message, autoNewLine)
```

#### `error`

Alias for `self.log(ERROR, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template error*(self: Logit, message = "", autoNewLine = true) =
  self.log(ERROR, message, autoNewLine)
```

#### `fatal`

Alias for `self.log(FATAL, message, autoNewLine)`. This an `{.inline.}` template.

**Implementation**

```nim
template fatal*(self: Logit, message = "", autoNewLine = true) =
  self.log(FATAL, message, autoNewLine)
```