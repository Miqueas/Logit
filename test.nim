import ./logit
from std/os import getCurrentDir

var log = initLogit(getCurrentDir(), "TEST", console = true, exit = false)

# Uses default logging level
log("hello!")
# Uses the given logging level
log(TRACE, "this seems to be working fine :)")
log(INFO, "this is an info message")
log(DEBUG, "this is a debug message")
log(WARN, "be careful 🔥")

# You can also do this
"hi there!".log()
TRACE.log("tracing data...")
WARN.log("something malicious is brewing 🤨")

log.header("hello there, this is a header :p")
log.test(29 > 30, "expected 29 > 30")
log.test(false, "expected `true`", lvl = FATAL)

log(ERROR, "something went wrong!!!")
log(FATAL, "O H   M Y   G O D N E S S")

log.done()