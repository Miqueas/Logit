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
  strutils,
  strformat,
]

type
  LogLevel* = enum OTHER, TRACE, INFO, DEBUG, WARN, ERROR, FATAL
  Logit* = object
  # Private
    file: File # Internal file used to write logs
    logsFolder: string # Path where logs are saved
  # Public
    filePrefix*: TimeFormat # Log file name prefix
    namespace*: string # Logging namespace
    exitOnError*: bool # Enable/disable calling `quit` in case of `ERROR` or `FATAL`
    logToFile*: bool # Enable/disable logging to file
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
    #                                    ^~ This one is used for the log level color
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
proc initLogit*(logsFolder = getTempDir(),
                namespace = "Logit",
                defaultLogLevel = OTHER,
                logToFile = true,
                logToConsole = false,
                exitOnError = false,
                filePrefix = initTimeFormat("YYYY-MM-dd")
               ): Logit {.raises: [IOError, ValueError].} =
  if not dirExists(logsFolder):
    raise newException(IOError, fmt"`{logsFolder}` isn't a valid path or doesn't exists")
  
  return Logit(
    logsFolder: logsFolder,
    filePrefix: filePrefix,
    namespace: namespace,
    exitOnError: exitOnError,
    logToFile: logToFile,
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
      self.file = open(self.logsFolder / filename, fmAppend)
    except:
      raise newException(IOError, fmt"can't open/write file {filename}")

# Logging API
template log*(self: Logit, level: LogLevel, message = $level) =
  let
    time = now().format(fmt.time)
    info = instantiationInfo(0)

  if self.logToFile:
    self.file.write(fmt.fileLine.format(time, self.namespace, $level, info.filename, info.line, message))

  if self.logToConsole:
    echo fmt.consoleLine.format(time, self.namespace, e(assoc[level]), $level, info.filename, info.line, message)

  if self.exitOnError and ord(level) > ord(WARN):
    if self.logToFile:
      self.file.write(fmt.fileExit.format(time))
      self.file.close()

    if self.logToConsole:
      quit(fmt.consoleExit.format(time, e(assoc[level])), QuitFailure)

    quit(QuitFailure)

# Shortcuts
{.push inline.}
template `()`*(self: Logit, level: LogLevel, message = $level) = self.log(level, message)
template log*(self: Logit, message = "") = self.log(self.defaultLogLevel, message)
template `()`*(self: Logit, message = "") = self.log(message)
template other*(self: Logit, message = "") = self.log(OTHER, message)
template trace*(self: Logit, message = "") = self.log(TRACE, message)
template info*(self: Logit, message = "") = self.log(INFO, message)
template debug*(self: Logit, message = "") = self.log(OTHER, message)
template warn*(self: Logit, message = "") = self.log(OTHER, message)
template error*(self: Logit, message = "") = self.log(OTHER, message)
template fatal*(self: Logit, message = "") = self.log(OTHER, message)
{.pop.}

# Writes a "header"
proc header*(self: Logit, message: string) =
  let time = now().format(fmt.time)
  if self.logToFile: self.file.write(fmt.fileHeader.format(time, message))
  if self.logToConsole: echo fmt.consoleHeader.format(time, message)

# Closes the internal file. Call this proc if you're sure you'll not need to use a `Logit` instance anymore
proc finish*(self: var Logit) {.inline.} = self.file.close()

# Getter for `path`
proc logsFolder*(self: Logit): string {.inline.} = return self.logsFolder

# Setter for `path`
proc `logsFolder=`*(self: var Logit, newLogsFolder: string) {.raises: [IOError, ValueError].} =
  if not dirExists(newLogsFolder):
    raise newException(IOError, fmt"`{newLogsFolder}` isn't a valid path or doesn't exists")

  self.logsFolder = newLogsFolder