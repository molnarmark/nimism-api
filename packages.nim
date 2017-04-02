import asyncdispatch, httpclient, json, strutils
import filters

var packageNodes* = seq[JsonNode](@[])

proc fetchPackages* =
  let resp = getContent("https://raw.githubusercontent.com/nim-lang/packages/master/packages.json")

  packageNodes = seq[JsonNode](@[])
  for node in parseJson($resp).items:
    packageNodes.add node

  writeFile("packages.json", $resp)

proc initPolling* {.async.} =
  while true:
    await sleepAsync 600 * 1000
    fetchPackages()

proc searchInPackages*(keyword: string): JsonNode =
  var response = newJArray()

  if not isFilter keyword:
    for node in packageNodes:
      if keyword in $node["name"]:
        response.add node

      for tagnode in node["tags"]:
        if keyword in $tagnode:
          if not response.contains node: response.add node
  else:
    var filters = parseFilters(keyword)
    response = filters.applyFilters(packageNodes)

  return response