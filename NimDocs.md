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

Most of Logit methods arguments are optionals and has its defaults values. Check out the exported symbols below.

### `enum LogLevel`

Definition:

  * `enum LogLevel` &ndash; supported logging levels by Logit
    - `field OTHER` &ndash; log level `OTHER`
    - `field TRACE` &ndash; log level `TRACE`
    - `field INFO` &ndash; log level `INFO`
    - `field DEBUG` &ndash; log level `DEBUG`
    - `field WARN` &ndash; log level `WARNING`
    - `field ERROR` &ndash; log level `ERROR`
    - `field FATAL` &ndash; log level `FATAL`

### `object Logit`

Definition:

  * `object Logit` &ndash; stores some practical data for logs
    - `field autoExit: bool` &ndash; enable/disable automatically calls `quit` if a log is level `ERROR` or `FATAL`
    - `field namespace: string` &ndash; the logging namespace
    - `field filePrefix: TimeFormat` &ndash; the log filename prefix
    - `field defaultLevel: LogLevel` &ndash; the log level
    - `field enableConsole: bool` &ndash; enable/disable logging to the console

I recommend to use `initLogit` to create an instance of this unless you're going to set all the fields.

### `proc initLogit -> Logit`

Definition:

  * `proc initLogit -> Logit` &ndash; creates a new `Logit` instance
    - `param path: string = getTempDir()` &ndash; sets `path`
    - `param name: string = "Logit"` &ndash; sets `namespace`
    - `param lvl: LogLevel = OTHER` &ndash; sets `defaultLevel`
    - `param console: bool = false` &ndash; sets `enableConsole`
    - `param exit: bool = true` &ndash; sets `autoExit`
    - `param prefix: TimeFormat = initTimeFormat("YYYY-MM-dd")` &ndash; sets `filePrefix`
    - `raises IOError` &ndash if `path` isn't valid or doesn't exists

Be careful when setting `path`.

### `proc prepare`

Definition:

  * `proc prepare` &ndash; prepares Logit for logging
    - `param self: var Logit` &ndash; the `Logit` instance
    - `raises IOError` &ndash; if can't write/open the log file

Use this proc if you already has a handmade `Logit` instance. This proc basically opens the log file to use it in your "logging session", using the data in the given `Logit` instance. This proc assumes that you already has set the `path` property.

### `template log`

Definition:

  * `template log` &ndash; makes a log
    - `param self: Logit` &ndash; your `Logit` instance
    - `param lvl: LogLevel` &ndash; the log level
    - `param logMsg: string = ""` &ndash; the log message
    - `param quitMsg: string = ""` &ndash; an optional exit message

`quitMsg` is used as final log message if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`

### `template log`

Definition:

  * `template log` &ndash; same as the above, but uses `defaultLevel` as log level
    - `param self: Logit` &ndash; your `Logit` instance
    - `param msg: string = ""` &ndash; the log message
    - `param quitMsg: string = ""` &ndash; an optional exit message

`quitMsg` is used as final log message if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`

### `template ()`

Definition:

  * `template ()` &ndash; `callOperator` for `Logit`, internally calls `log`
    - `param self: Logit` &ndash; your `Logit` instance
    - `param lvl: LogLevel` &ndash; the log level
    - `param msg: string = ""` &ndash; the log message
    - `param quitMsg: string = ""` &ndash; an optional exit message

`quitMsg` is used as final log message if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`

### `template ()`

Definition:

  * `template ()` &ndash; `callOperator` for `Logit`, internally calls `log` with `defaultLevel` as log level
    - `param self: Logit` &ndash; your `Logit` instance
    - `param msg: string = ""` &ndash; the log message
    - `param quitMsg: string = ""` &ndash; an optional exit message

`quitMsg` is used as final log message if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`

### `template expect`

Definition:

  * `template expect` &ndash; calls `log` with level `lvl` if the given "expression" `exp` is `false`
    - `param self: Logit` &ndash; your `Logit` instance
    - `param exp: bool` &ndash; the "expression" to evaluate
    - `param msg: string = ""` &ndash; the log message
    - `param lvl: LogLevel = ERROR` &ndash; the log level, but defaults to `ERROR`
    - `param quitMsg: string = ""` &ndash; an optional exit message

This maybe useless if `autoExit` is disabled, since was made mainly for errors.

### `proc header`

Definition:

  * `proc header` &ndash; writes a "header"
    - `param self: Logit` &ndash; your `Logit` instance
    - `param msg: string` &ndash; the header message

### `proc done`

Definition:

  * `proc done` &ndash; closes the internal file
    - `param self: var Logit` &ndash; your `Logit` instance

### `proc path -> string`

Definition:

  * `proc path -> string` &ndash; getter for `path`
    - `param self: Logit` &ndash; your `Logit` instance

### `proc path=`

Definition:

  * `proc path=` &ndash; setter for `path`
    - `param self: var Logit` &ndash; your `Logit` instance
    - `param newPath: string` &ndash; the new path
    - `raises IOError` &ndash if `newPath` isn't valid or doesn't exists

You should use this once, since the log file is open once and changing the `path` after calling `prepare` will not affect the log file path. Except if you do something like this:

````nim
import logit

var log = Logit()
log.path = "/a/path"
log.prepare()

# ...

log.done()

log.path = "/another/path"
# i'm not sure if this will work
log.prepare()

# ...

log.done()
```

It makes no sense setting `path` between `prepare` and `done`.