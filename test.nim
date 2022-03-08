import logit
from std/os import getCurrentDir

let logger = newLogit(path = getCurrentDir(), name = "TEST", console = true)

# Uses default logging level
logger("hello!")
logger(TRACE, "this seems to be working fine :)")
logger(INFO, "this is an info message")
logger(DEBUG, "🔥")
logger(WARN, "WARNING!!!!")

logger.header("hello there, this is a header :p")
logger.expect(29 < 30, "Expected 29 < 30")

logger(ERROR, "E")
# Never runs
logger(FATAL, "F")