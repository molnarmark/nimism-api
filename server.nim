import jester, asyncdispatch, htmlgen, json, strutils

proc generateResponse(keyword: string): JsonNode =
  var response = newJArray()
  var nodes = parseFile("packages.json")
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


runForever()