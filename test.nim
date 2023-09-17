import ./logit
from std/os import getCurrentDir

var log = initLogit(getCurrentDir(), "TEST", logToConsole = true, exitOnError = false)
log.start()

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

log(ERROR, "something went wrong!!!")
log(FATAL, "O H   M Y   G O D N E S S")

log.finish()