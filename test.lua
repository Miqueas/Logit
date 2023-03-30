local logit = require("logit")

local log = logit:new("./", "Test", nil, true, false)

log(nil, "hello!")
log(logit.TRACE, "this seems to be working fine :)")
log(logit.INFO, "this is an info message")
log(logit.DEBUG, "this is a debug message")
log(logit.WARN, "be careful 🔥")

log:header("hello there, this is a header :P")

-- Checks if 'e' exists
log:test(5 > 6, "5 > 6 == true")
log:test(e, "'e' doesn't exists", logit.FATAL)
log:test()

log(logit.ERROR, "something went wrong!!!")
log(logit.FATAL, "O H   M Y   G O D N E S S")
log:done()