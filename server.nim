import jester, asyncdispatch, htmlgen, json, strutils, httpclient, posix, logging
import packages

var packagesLogger = newFileLogger("server.log")
addHandler(packagesLogger)

routes:
  get "/search/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $searchInPackages(@"keyword")
  get "/package/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $getPackageDetails(@"keyword")

onSignal(SIGINT, SIGTERM):
  packagesLogger.log lvlAll, "Crash incoming"
  quit()

proc main() =
  asyncCheck initPolling()
  runForever()

when isMainModule:
  main()