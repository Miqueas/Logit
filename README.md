# Logger

Logger is a small log utility library for Lua that you can use like `assert()` and allows write logs to files and/or console. Logger is easy to use, here's a simple example:

```lua
local Logger = require("Logger")
local log = Logger("MyScript", os.getenv("HOME"), true)

-- maybe lots of code here...

local userConf = load_user_config() -- example function...
log:log(userConf, "error", "user configuration can't be loaded")

-- more code here
```

You will get an output like this:

![Capture 1](cap1.png)

And a file in your `$HOME` called `MyScript_DATE.log` (where `DATE` is the result of `os.date("%Y-%m-%d")`) with a content like this:

```
17:15:58 [MyScript ERROR] MyScript.lua@3: user configuration can't be loaded
```

### Dependencies

Before to start reading the docs, you need to know that Logger requires 2 libraries:

  1. [Self][SelfRepo] (I want to drop this dependencies later)
  2. [TermColors][TCRepo]

Self is for OOP and TermColors is for the colored output in console.

### Docs

Logger provides only 2 functions/methods:

  * `new([name, dir, console])`: Constructor. Same as `Logger()`. This function is only for a more comfortable use and the purpose is basically prepare few elements for the `log()` function. Arguments:
    * (__string__) `name` The name of your app/script/project, etc. Basically a namespace, useful if you want to use various Logger instances.
    * (__string__) `dir` An existing directory when Logger saves log files. If `dir` doesn't exists, you will get an error.
    * (__boolean__) `console` Set to `true` if you want that Logger to the console (`stdout`) too. `false` by default, Logger only write log files.

  * `log(exp, lvl, msg, ...)`: Well... Write logs... Arguments:
    * (__any__) `exp` Like `assert()`, if this argument is `nil` or `false`, then Logger write the log message and, if the log level is 5, 6 or 7, Logger stops the script.
    * (__number__ or __string__) `lvl` The log level (see the table below).
    * (__string__) `msg` The log message. Also supports the [TermColors][TCRepo] markup.
    * (__any__) `...` Varargs, used with `string.format()` for push values in `msg`.

The `log()` function accepts the following values in the `lvl` argument:

| Number\* | String\*\* |
| :----- | :----- |
| `1` | `"trace"` |
| `2` | `"debug"` |
| `3` | `"info"`  |
| `4` | `"warn"`  |
| `5` | `"error"` |
| `6` | `"fatal"` |
| `7` | `"other"` |

__\*__: the preferred number value.

__\*\*__: the string equivalent allowed value.

For numbers in the `log()` function, if is diferent of one in the above table, then you will get an error. For strings, if is diferent of one in the above table, then is ignored and the log is write as a level 7.

[SelfRepo]: https://github.com/M1que4s/Self
[TCRepo]: https://github.com/M1que4s/TermColors