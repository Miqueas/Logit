import logit
from std/os import getCurrentDir, getTempDir

var logger = initLogit(getCurrentDir(), "TEST", console = true, exit = false)

# Uses default logging level
logger("hello!")
logger(TRACE, "this seems to be working fine :)")
logger(INFO, "this is an info message")
logger(DEBUG, "this is a debug message")
logger(WARN, "be careful 🔥")

logger.header("hello there, this is a header :p")
logger.expect(29 < 30, "Expected 29 > 30")

logger(ERROR, "something went wrong!!!")
# Never runs
logger(FATAL, "O H   M Y   G O D N E S S")
logger.done()