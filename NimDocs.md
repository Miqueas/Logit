# Usage

A very simple example

```nim
import logit
from std/os import getCurrentDir

var log = initLogit(getCurrentDir(), "MyApp")

log(INFO, "application started")
# your code...

log.done()
```

Check out the [test file](test.nim) for a better example

## API

Logit exports an small set of things

  * `enum LogLevel` &ndash; supported logging levels by Logit
    - `field OTHER` &ndash; log level `OTHER`
    - `field TRACE` &ndash; log level `TRACE`
    - `field INFO` &ndash; log level `INFO`
    - `field DEBUG` &ndash; log level `DEBUG`
    - `field WARN` &ndash; log level `WARNING`
    - `field ERROR` &ndash; log level `ERROR`
    - `field FATAL` &ndash; log level `FATAL`
  * `object Logit` &ndash; stores some practical data for logs
    - `field autoExit: bool` &ndash; enable/disable automatically calls `quit` if a log is level `ERROR` or `FATAL`
    - `field namespace: string` &ndash; the logging namespace
    - `field filePrefix: TimeFormat` &ndash; the log filename prefix
    - `field defaultLevel: LogLevel` &ndash; the log level
    - `field enableConsole: bool` &ndash; enable/disable logging to the console
  * `proc initLogit: Logit` &ndash; creates a new `Logit` instance
    - `param path: string = getTempDir()` &ndash; sets `path`
    - `param name: string = "Logit"` &ndash; sets `namespace`
    - `param lvl: LogLevel = OTHER` &ndash; sets `defaultLevel`
    - `param console: bool = false` &ndash; sets `enableConsole`
    - `param exit: bool = true` &ndash; sets `autoExit`
    - `param prefix: TimeFormat = initTimeFormat("YYYY-MM-dd")` &ndash; sets `filePrefix`
    - `raises IOError` &ndash if `path` isn't valid or doesn't exists
  * `proc prepare: Logit` &ndash; prepares (creates the log file) Logit for logging using the given `Logit` instance, use this if you has a handmade `Logit` instance, this proc assumes that you already has set the `path` property
    - `param self: var Logit` &ndash; the `Logit` instance
    - `raises IOError` &ndash; if can't write/open the log file
  * `template log` &ndash; makes a log
    - `param self: Logit` &ndash; your `Logit` instance
    - `param lvl: LogLevel` &ndash; the log level
    - `param logMsg: string = ""` &ndash; the log message
    - `param quitMsg: string = ""` &ndash; an optional message to write if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`
  * `template log` &ndash; same as the above `log`, but uses `defaultLevel` as log level
    - `param self: Logit` &ndash; same as in `log`
    - `param msg: string = ""` &ndash; same as in `log`
    - `param quitMsg: string = ""` &ndash; same as in `log`
  * `template ()` &ndash; `callOperator` for `Logit`, internally calls `log`
    - `param self: Logit` &ndash; same as in `log`
    - `param lvl: LogLevel` &ndash; same as in `log`
    - `param msg: string = ""` &ndash; same as in `log`
    - `param quitMsg: string = ""` &ndash; same as in `log`
  * `template ()` &ndash; `callOperator` for `Logit`, internally calls `log` with `defaultLevel` as log level
    - `param self: Logit` &ndash; same as in `log`
    - `param msg: string = ""` &ndash; same as in `log`
    - `param quitMsg: string = ""` &ndash; same as in `log`