local Logit, LogLevel = require("logit")()

local log = Logit:new(".", "Test", nil, true, true)
log:start()

log(nil, "hello!")
log(LogLevel.TRACE, "this seems to be working fine :)")
log(LogLevel.INFO, "this is an info message")
log(LogLevel.DEBUG, "this is a debug message")
log(LogLevel.WARN, "be careful 🔥")

log:header("hello there, this is a header :P")

log(LogLevel.ERROR, "something went wrong!!!")
log(LogLevel.FATAL, "O H   M Y   G O D N E S S")
log:finish()