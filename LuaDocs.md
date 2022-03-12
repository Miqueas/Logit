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
    - `field OTHER: number = 0` &ndash; log level `OTHER`
    - `field TRACE: number = 1` &ndash; log level `TRACE`
    - `field INFO: number = 2` &ndash; log level `INFO`
    - `field DEBUG: number = 3` &ndash; log level `DEBUG`
    - `field WARN: number = 4` &ndash; log level `WARNING`
    - `field ERROR: number = 5` &ndash; log level `ERROR`
    - `field FATAL: number = 6` &ndash; log level `FATAL`
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
      - **Required?**: no
      - **Default**: system temp dir
    - `param name: string` &ndash; sets `namespace`
      - **Required?**: no
      - **Default**: `"Logit"`
    - `param lvl: number` &ndash; sets `defaultLevel`
      - **Required?**: no
      - **Default**: `OTHER`
    - `param console: boolean` &ndash; sets `enableConsole`
      - **Required?**: no
      - **Default**: `false`
    - `param exit: boolean` &ndash; sets `autoExit`
      - **Required?**: no
      - **Default**: `true`
    - `param prefix: string` &ndash; sets `filePrefix`
      - **Required?**: no
      - **Default**: `"%Y-%m-%d"`

This method can throw an error if `path` isn't valid or doesn't exists and `prefix` must be a valid string (check out `os.date` doc).

### `method Logit:log`

Definition:

  * `method Logit:log` &ndash; makes a log
    - `param lvl: number` &ndash; the log level
      - **Required?**: no
      - **Default**: `defaultLevel`
    - `param msg: string` &ndash; the log message
      - **Required?**: no
      - **Default**: the log level name
    - `param quitMsg: string` &ndash; an optional exit message
      - **Required?**: no
      - **Default**: `msg`
    - `param ...` &ndash; varargs to use for `msg`
      - **Required?**: only if you're going to format `msg`

If `msg` is `nil`, the log level will be the message (by example, "INFO" for `INFO`). `quitMsg` is used as final log message if `autoExit` is enabled and `lvl` is `ERROR` or `FATAL`

### `method Logit:expect -> Expr`

Definition:

  * `method Logit:expect -> Expr` &ndash; calls `log` with level `lvl` if the given "expression" `exp` is `false` or `nil`
    - `param exp: Expr` &ndash; the "expression" to evaluate
      - **Required?**: yes
    - `param msg: string` &ndash; the log message
      - **Required?**: no
      - **Default**: the log level name
    - `param lvl: number` &ndash; the log level, but defaults to `ERROR`
      - **Required?**: no
      - **Default**: `ERROR`
    - `param quitMsg: string` &ndash; an optional exit message
      - **Required?**: no
      - **Default**: `msg`
    - `param ...` &ndash; varargs to use for `msg`
      - **Required?**: only if you're going to format `msg`

If `exp` isn't `false` or `nil`, then returns it. This method maybe useless if `autoExit` is disabled, since was made mainly for errors.

### `method Logit:header`

Definition:

  * `method Logit:header` &ndash; writes a "header"
    - `param msg: string` &ndash; the header message
      - **Required?**: yes

### `method Logit:done`

Definition:

  * `method Logit:done` &ndash; closes the internal file

You must call this only if you're sure that you'll don't need a `Logit` instance anymore (at the end of your app by example)