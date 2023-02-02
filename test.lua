local logit = require("logit")

local log = logit:new("./", "TEST", nil, true, false)

log(nil, "hello!")
log(logit.TRACE, "this seems to be working fine :)")
log(logit.INFO, "this is an info message")
log(logit.DEBUG, "this is a debug message")
log(logit.WARN, "be careful 🔥")

log:header("hello there, this is a header :p")
log:expect(29 > 30, "expected 29 > 30")
log:expect(false, "expected `true`", logit.FATAL)

log(logit.ERROR, "something went wrong!!!")
log(logit.FATAL, "O H   M Y   G O D N E S S")
log:done()