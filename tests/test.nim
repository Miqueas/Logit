import ../logit
import std/os

let logger = newLogit(path = getCurrentDir(), name = "Test", console = true)

# Uses default logging level
logger("O")
logger(TRACE, "T")
logger(DEBUG, "D")
logger(INFO, "I")
logger(WARN, "W")
logger.header("hello")
logger.expect(29 < 30, "Expected 29 < 30")
logger(ERROR, "E")
# Never runs
logger(FATAL, "F")