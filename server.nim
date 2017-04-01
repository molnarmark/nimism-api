import jester, asyncdispatch, htmlgen, json, strutils, httpclient
import packages

routes:
  get "/search/@keyword":
    resp Http200, [("Access-Control-Allow-Origin", "*")], $searchInPackages(@"keyword")

proc main() =
  fetchPackages()
  asyncCheck initPolling()
  runForever()

main()