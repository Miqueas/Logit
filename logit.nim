#[
  Author: Miqueas Martínez (https://github.com/Miqueas)
  Co-Author: Nelson "darltrash" López (https://github.com/darltrash)
  Date: 2020/09/12
  License: zlib (see it in the repository)
  Git Repository: https://github.com/Miqueas/Logit
]#

import std/[
  os,
  times,
  tables,
  syncio,
  strutils,
  strformat,
]

type
  LogLevel* = enum OTHER, TRACE, INFO, DEBUG, WARN, ERROR, FATAL
  Logit* = object
    # Private
    file: File # Internal file used to write logs
    logsDir: string # Path where logs are saved
    # Public
    namespace*: string # Logging namespace
    logToFile*: bool # Enable/disable logging to file
    filePrefix*: TimeFormat # Log file name prefix
    exitOnError*: bool # Enable/disable calling `quit` in case of `ERROR` or `FATAL`
    logToConsole*: bool # Enable/disable logging to console
    defaultLogLevel*: LogLevel # Default logging level

proc e(n: varargs[int]): string = return '\e' & '[' & join(n, ";") & 'm'

proc `$`*(lvl: LogLevel): string =
  return case lvl:
    of OTHER: "OTHER"
    of TRACE: "TRACE"
    of INFO: "INFO."
    of DEBUG: "DEBUG"
    of WARN: "WARN."
    of ERROR: "ERROR"
    of FATAL: "FATAL"

const
  fmt = (
    fileName: "$1_$2.log",
    time: "HH:mm:ss",
    fileLine: "$1 [$2 $3] $4:$5 $6\n",
    consoleLine: fmt"{e(2)}$1 [{e(0,1)}$2 $3$4{e(0,2)}] $5:$6{e(0)} $7",
    #                                  ^~ This one is used for the log level color
    fileHeader: "\n$1 [$2]\n\n",
    consoleHeader: '\n' & fmt"{e(2)}$1 [{e(0, 1)}$2{e(0, 2)}]{e(0)}" & '\n',
    fileExit: "$1 [EXIT]\n",
    consoleExit: fmt"{e(2)}$1 [{e(0, 1)}$2EXIT{e(0, 2)}]{e(0)}",
    #                                   ^~ This one is used for the log level color
  )
  assoc = toTable({
    OTHER: 30,
    TRACE: 32,
    INFO: 34,
    DEBUG: 36,
    WARN: 33,
    ERROR: 31,
    FATAL: 35,
  })

# Creates a new `Logit` object using the given properties
# or fallback to default values if not arguments
# given
proc initLogit*(
  logsDir = getTempDir(),
  namespace = "Logit",
  logToFile = true,
  filePrefix = initTimeFormat("YYYY-MM-dd"),
  exitOnError = false,
  logToConsole = false,
  defaultLogLevel = OTHER,
): Logit {.raises: [IOError].} =
  if not dirExists(logsDir):
    raise newException(IOError, fmt"`{logsDir}` isn't a valid path or doesn't exists")

  return Logit(
    logsDir: logsDir,
    namespace: namespace,
    logToFile: logToFile,
    filePrefix: filePrefix,
    exitOnError: exitOnError,
    logToConsole: logToConsole,
    defaultLogLevel: defaultLogLevel
  )

# Prepares Logit for logging using the given `Logit` instance.
# This function assumes that `Logit` has everything ready to
# start logging, that means you must have set the `path` property
proc start*(self: var Logit) {.raises: [IOError, ValueError].} =
  if self.logToFile:
    let
      date = now().format(self.filePrefix)
      filename = fmt.fileName.format(date, self.namespace)

    try:
      self.file = open(self.logsDir / filename, fmAppend)
    except:
      raise newException(IOError, fmt"can't open/write file {filename}")

# Logging API
template log*(self: Logit, level: LogLevel, message = $level, autoNewLine = true) =
  let
    time = now().format(fmt.time)
    info = instantiationInfo(0)

  if self.logToFile:
    let msg = fmt.fileLine.format(time, self.namespace, $level, info.filename, info.line, message)

    if autoNewLine: self.file.write(msg)
    else: self.file.write(msg.substr(0, msg.len - 2))

  if self.logToConsole:
    let msg = fmt.consoleLine.format(time, self.namespace, e(assoc[level]), $level, info.filename, info.line, message)

    if autoNewLine: echo msg
    else:
      stdout.write(msg)
      stdout.flushFile()

  if self.exitOnError and ord(level) > ord(WARN):
    if self.logToFile:
      self.file.write(fmt.fileExit.format(time))
      self.file.close()

    if self.logToConsole:
      quit(fmt.consoleExit.format(time, e(assoc[level])), QuitFailure)

    quit(QuitFailure)

# Shortcuts
{.push inline.}
template `()`*(self: Logit, level: LogLevel, message = $level, autoNewLine = true) =
  self.log(level, message, autoNewLine)
template log*(self: Logit, message = "", autoNewLine = true) = self.log(self.defaultLogLevel, message, autoNewLine)
template `()`*(self: Logit, message = "", autoNewLine = true) = self.log(message, autoNewLine)
template other*(self: Logit, message = "", autoNewLine = true) = self.log(OTHER, message, autoNewLine)
template trace*(self: Logit, message = "", autoNewLine = true) = self.log(TRACE, message, autoNewLine)
template info*(self: Logit, message = "", autoNewLine = true) = self.log(INFO, message, autoNewLine)
template debug*(self: Logit, message = "", autoNewLine = true) = self.log(OTHER, message, autoNewLine)
template warn*(self: Logit, message = "", autoNewLine = true) = self.log(OTHER, message, autoNewLine)
template error*(self: Logit, message = "", autoNewLine = true) = self.log(OTHER, message, autoNewLine)
template fatal*(self: Logit, message = "", autoNewLine = true) = self.log(OTHER, message, autoNewLine)
{.pop.}

# Writes a "header"
proc header*(self: Logit, message: string) =
  let time = now().format(fmt.time)
  if self.logToFile: self.file.write(fmt.fileHeader.format(time, message))
  if self.logToConsole: echo fmt.consoleHeader.format(time, message)

# Closes the internal file. Call this proc if you're sure you'll not need to use a `Logit` instance anymore
proc finish*(self: var Logit) {.inline.} = self.file.close()

# Getter for `path`
proc logsDir*(self: Logit): string {.inline.} = return self.logsDir

# Setter for `path`
proc `logsDir=`*(self: var Logit, newLogsDir: string) {.raises: [IOError, ValueError].} =
  if not dirExists(newLogsDir):
    raise newException(IOError, fmt"`{newLogsDir}` isn't a valid path or doesn't exists")

  self.logsDir = newLogsDir