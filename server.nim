import jester, asyncdispatch, htmlgen, json, strutils, httpclient, posix, logging
import packages

var serverLogger = newFileLogger("server.log")
addHandler(serverLogger)

routes:
  get "/search/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $searchInPackages(@"keyword")
  get "/package/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $getPackageDetails(@"keyword")

onSignal(SIGINT, SIGTERM):
  serverLogger.log lvlAll, "Crash incoming"
  quit()

proc main() =
  asyncCheck initPolling()
  runForever()

when isMainModule:
  main()