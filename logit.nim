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
  LogLevel* = enum
    OTHER,
    TRACE,
    INFO,
    DEBUG,
    WARN,
    ERROR,
    FATAL

  Logit* = object
    file: File
    path: string
    autoExit*: bool
    namespace*: string
    filePrefix*: TimeFormat
    defaultLevel*: LogLevel
    enableConsole*: bool

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
#[
  assoc = [
    ( name: "OTHER", color: 30 ),
    ( name: "TRACE", color: 32 ),
    ( name: "INFO.", color: 34 ),
    ( name: "DEBUG", color: 36 ),
    ( name: "WARN.", color: 33 ),
    ( name: "ERROR", color: 31 ),
    ( name: "FATAL", color: 35 )
  ]
]#

# Prepares Logit for logging using the given `Logit` instance.
# This function assumes that `Logit` has everything ready to
# start logging, that means you must have set the `path` property
proc prepare*(self: var Logit) {.raises: [IOError, ValueError].} =
  let
    dt = now()
    date = dt.format(self.filePrefix)
    filename = fmt.fileName.format(date, self.namespace)

  try:
    self.file = open(self.path / filename, fmAppend)
  except:
    raise newException(IOError, fmt"can't open/write file {filename}")

# Creates a new `Logit` instance using the given properties
# or fallback to default values if not arguments
# given
proc initLogit*(path = getTempDir(),
                name = "Logit",
                lvl = OTHER,
                console = false,
                exit = true,
                prefix = initTimeFormat("YYYY-MM-dd")
               ): Logit {.raises: [IOError, ValueError].} =
  if not dirExists(path):
    raise newException(IOError, fmt"`{path}` isn't a valid path or doesn't exists")
  
  var self = Logit(
    path: path,
    autoExit: exit,
    namespace: name,
    filePrefix: prefix,
    defaultLevel: lvl,
    enableConsole: console
  )

  self.prepare()
  return self

# Logging API
template log*(self: Logit, lvl: LogLevel, logMsg = "", quitMsg = "") =
  let
    time = now().format(fmt.time)
    msg =
      if logMsg == "": $lvl
      else: logMsg
    info = instantiationInfo(0)

  self.file.write(fmt.fileLine.format(time, self.namespace, $lvl, info.filename, info.line, msg))

  if self.enableConsole:
    echo fmt.consoleLine.format(time, self.namespace, e(assoc[lvl]), $lvl, info.filename, info.line, msg)

  if ord(lvl) > 4 and self.autoExit:
    self.file.write(fmt.fileExit.format(time))
    self.file.close()

    if self.enableConsole:
      quit(fmt.consoleExit.format(time, e(assoc[lvl])), 1)
    else:
      quit(1)

# Some "shortcuts"
{.push inline.}
template log*(self: Logit, msg = "", quitMsg = "") =
  self.log(self.defaultLevel, msg, quitMsg)

template `()`*(self: Logit, msg = "", quitMsg = "") =
  self.log(self.defaultLevel, msg, quitMsg)

template `()`*(self: Logit, lvl: LogLevel, msg = "", quitMsg = "") =
  self.log(lvl, msg, quitMsg)
{.pop.}

# Automatically logs an error if `exp` is `false`. If autoExit is `false` you may don't need/want to use this proc
template test*(self: Logit, exp: bool, msg = "given expression went wrong", lvl = ERROR): untyped =
  if not exp: self.log(lvl, msg)

# Writes a "header"
proc header*(self: Logit, msg: string) =
  let time = now().format(fmt.time)
  
  self.file.write(fmt.fileHeader.format(time, msg))

  if self.enableConsole:
    echo fmt.consoleHeader.format(time, msg)

# Closes the internal file. Call this proc if you're sure you'll not need to use a `Logit` instance anymore
proc done*(self: var Logit) {.inline.} =
  self.file.close()

# Getter for `path`
proc path*(self: Logit): string {.inline.} =
  return self.path

# Setter for `path`
proc `path=`*(self: var Logit, newPath: string) {.raises: [IOError, ValueError].} =
  if not dirExists(newPath):
    raise newException(IOError, fmt"`{newPath}` isn't a valid path or doesn't exists")
  self.path = newPath