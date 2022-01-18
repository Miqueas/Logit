import Logit
import std/os

let logger = newLogit(path = getCurrentDir(), name = "Test", console = true)

logger.log("O")
logger.log(TRACE, "T")
logger.log(DEBUG, "D")
logger.log(INFO, "I")
logger.log(WARN, "W")
logger.header("hello")
logger.log(ERROR, "E")
logger.log(FATAL, "F")
