import jester, asyncdispatch, htmlgen, json, strutils, httpclient

var nodes = parseFile("packages.json")

proc generateResponse(keyword: string): JsonNode =
  var response = newJArray()
  for node in nodes:
    if keyword in $node["name"]:
      response.add node

    for tagnode in node["tags"]:
      if keyword in $tagnode:
        if not response.contains node: response.add node

  return response

routes:
  get "/search/@keyword":
    var keyword = @"keyword"
    resp(Http200, [("Access-Control-Allow-Origin", "*")], $generateResponse(keyword))


proc pollPackages {.async.} =
  while true:
    await sleepAsync 600 * 1000
    let resp = getContent("https://raw.githubusercontent.com/nim-lang/packages/master/packages.json")
    nodes = parseJson($resp)
    writeFile("packages.json", $resp)

proc main() =
  asyncCheck pollPackages()
  runForever()

main()