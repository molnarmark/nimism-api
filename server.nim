import jester, asyncdispatch, htmlgen, json, strutils, httpclient, posix, logging
import packages

var packagesLogger = newFileLogger("packages.log", fmtStr = verboseFmtStr)
addHandler(packagesLogger)

routes:
  get "/search/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $searchInPackages(@"keyword")

onSignal(SIGINT, SIGTERM):
  packagesLogger.log lvlAll, "Crash incoming.."

proc main() =
  fetchPackages()
  asyncCheck initPolling()
  runForever()

when isMainModule:
  main()