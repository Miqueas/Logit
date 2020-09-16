# Logger

Logger is a small utility library for Lua records that you can easily integrate into your projects.
Here a small example:

```lua
local Logger = require("Logger")
local log = Logger("MyScript", os.getenv("HOME"), true)
log("Log library started!", "info")
log("This is a debug message")

-- Something of code here...

local config = load_config() -- example function...
-- Like assert() function
log:expect(type(config) == "table", "user config can't be loaded")

-- More code here...
```

You will get an output like this:

![Capture 1](capture.png)

And a file in your `$HOME` folder called `MyScript_DATE.log` (where `DATE` is the result of `os.date("%Y-%m-%d")`) with content like this:

```
11:43:55 [AUTOGENERATED BY LOGGER]
11:43:55 [MyScript INFO.] Test.lua@3: Log library started!
11:43:55 [MyScript DEBUG] Test.lua@4: This is a debug message
11:43:55 [MyScript ERROR] Test.lua@10: user config can't be loaded

11:43:55 [SOMETHING WENT WRONG!]
```

### Documentación

Logger provides 6 functions/methods:

  * `new([name, dir, console, suffix, header, ...])`: Constructor. Same as `Logger()`. This function is mainly for a more comfortable use of the library and basically prepares some elements to be used by the `log()` function. Arguments (optionals):
    * (__string__) `name` The name of your application/project/script, among others. Basically a name that you can identify with something in particular, is useful if you plan to use several instances of Logger.
    * (__string__) `dir` An existing directory where Logger will store the log files. If it does not exist, you will get an error.
    * (__boolean__) `console` By default, Logger only writes log files, but if this argument is `true`, then it will also write logs to the terminal/console.
    * (__string__) `suffix` You can change the default file suffix, which is: 'Year-Month-Day' in numbers. This argument _should_ be a string with a format accepted by `os.date()`.
    * (__string__) `header` When this function is called to create a logger instance, a header is always written before all the records in the file, which is "AUTOGENERATED BY LOGGER". With this argument you can change that text.
    * (__any__) `...` Varargs used with `string.format()` for the `header` argument

  * `log(msg [, lvl, ...])`: The main function that writes records. In a Logger instance it can be called with `log()` instead of `log:log()`. Arguments:
    * (__string__) `msg` The message you want to log.
    * (__string [opcional]__) `lvl` The log level (see list below).
    * (__any [opcional]__) `...` Varargs used with `string.format()` to place values in `msg`.

  * `expect(exp, msg [, lvl, ...])`: The equivalent of `assert()`. If the `exp` argument is `false` or `nil` then the `msg` message is logged. With the exception of `exp`, all other arguments work as in `log()`:
    * (__any__) `exp` A Lua expression.
    * (__string__) `msg` The message you want to log.
    * (__string [opcional]__) `lvl` The log level (see list below).
    * (__any [opcional]__) `...` Varargs used with `string.format()` to place values in `msg`.

  * `header(msg, ...)`: Write a header that can be used in different ways, such as separating records or creating "breakpoints", among others. Arguments:
    * (__string__) `msg`The message you want to log.
    * (__any__) `...` Varargs for `msg`.

  * `setLogLvl(lvl)`: Logger now internally handles a default logging level so that, if not specified, that value is used instead. With this function you can change this value safely. Arguments:
    * (__string__) `lvl` The new default log level.

  * `setFileSuffix(fmt)`: Changes the suffix used in the log file names. Note that this means that several log files can be generated and the logs generated by Logger could be written to different files. Arguments:
    * (__string__) `fmt` The new format. As in the Logger constructor, it is expected to be a text supported by `os.date()`.

The function `log()` and `expect()` accept the following values in the `lvl` argument (referring to the "level of importance"):

  * `"other"`
  * `"trace"`
  * `"debug"`
  * `"info"`
  * `"warn"`
  * `"error"`
  * `"fatal"`

These values follow a level from 0 (`"other"`) to 6 (`"fatal"`). A value higher than 4 (`"warn"`) causes Logger to stop the execution of Lua.