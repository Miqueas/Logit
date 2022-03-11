# Usage

A very simple example.

```lua
local logit = require("logit")

local log = logit:new("./", "MyApp")

log(logit.INFO, "application started")
-- your code...

log:done()
```

Check out the [test file](test.lua) for a better example

## API

Most of Logit methods arguments are optionals and has its defaults values. They also has `string.format` built-in support, that's means, methods with `...` arguments uses that for string formatting.

### `class Logit`

Definition:

  * `class Logit` &ndash; stores some practical data for logs
    - `field OTHER = 0` &ndash; log level `OTHER`
    - `field TRACE = 1` &ndash; log level `TRACE`
    - `field INFO = 2` &ndash; log level `INFO`
    - `field DEBUG = 3` &ndash; log level `DEBUG`
    - `field WARN = 4` &ndash; log level `WARNING`
    - `field ERROR = 5` &ndash; log level `ERROR`
    - `field FATAL = 6` &ndash; log level `FATAL`
    - `field path: string` &ndash; the path where logs will be saved
    - `field autoExit: boolean` &ndash; enable/disable automatically calls `quit` if a log is level `ERROR` or `FATAL`
    - `field namespace: string` &ndash; the logging namespace
    - `field filePrefix: string` &ndash; the log filename prefix
    - `field defaultLevel: number` &ndash; the log level
    - `field enableConsole: boolean` &ndash; enable/disable logging to the console

You must use `Logit:new` to construct a instance of this class.

### `method Logit:new`

Definition:

  * `method Logit:new -> Logit` &ndash; creates a new `Logit` instance
    - `param path: string` &ndash; sets `path`
    - `param name: string` &ndash; sets `namespace`
    - `param lvl: number` &ndash; sets `defaultLevel`
    - `param console: boolean` &ndash; sets `enableConsole`
    - `param exit: boolean` &ndash; sets `autoExit`
    - `param prefix: string` &ndash; sets `filePrefix`

This method can throw an error if `path` isn't valid or doesn't exists.
`prefix` must be a valid string (check out `os.date` doc).

### `method Logit:log`

Definition:

  * `method Logit:log` &ndash; makes a log
    - `param lvl: number` &ndash; the log level
    - `param msg: string` &ndash; the log message
    - `param quitMsg: string` &ndash; an optional exit message
    - `param ...` &ndash; varargs to use for `msg`

If `msg` is `nil`, the log level will be the message (by example, "INFO" for `INFO`).
If `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`, `quitMsg` will be used as a final "exit" message to quit the program.

### `method Logit:expect -> Expr`

Definition:

  * `method Logit:expect -> Expr` &ndash; calls `log` with level `lvl` if the given "expression" `exp` is `false`
    - `param exp: Expr` &ndash; the "expression" to evaluate
    - `param msg: string` &ndash; the log message
    - `param lvl: number` &ndash; the log level, but defaults to `ERROR`
    - `param quitMsg: string` &ndash; an optional exit message
    - `param ...` &ndash; varargs to use for `msg`

### `method Logit:header`

Definition:

  * `method Logit:header` &ndash; writes a "header"
    - `param msg: string` &ndash; the header message

### `method Logit:done`

Definition:

  * `method Logit:done` &ndash; closes the internal file