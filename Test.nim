import logit
import std/os

let logger = newLogit(path = getCurrentDir(), name = "Test", console = true)

logger.log("O")
logger.log(TRACE, "T")
logger.log(DEBUG, "D")
logger.log(INFO, "I")
logger.log(WARN, "W")
logger.header("hello")
logger.expect(29 < 30, "Expected 29 < 30")
logger.log(ERROR, "E")
# Never runs
logger.log(FATAL, "F")