import logit
from std/os import getCurrentDir

var log = initLogit(getCurrentDir(), "TEST", console = true, exit = false)

# Uses default logging level
log("hello!")
log(TRACE, "this seems to be working fine :)")
log(INFO, "this is an info message")
log(DEBUG, "this is a debug message")
log(WARN, "be careful 🔥")

log.header("hello there, this is a header :p")
log.expect(29 < 30, "Expected 29 > 30")

log(ERROR, "something went wrong!!!")
# Never runs
log(FATAL, "O H   M Y   G O D N E S S")
log.done()