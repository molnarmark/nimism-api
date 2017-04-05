import asyncdispatch, httpclient, json, strutils
import filters
import logging

var packageNodes* = seq[JsonNode](@[])
var packagesLogger = newFileLogger("packages.log", fmtStr = verboseFmtStr)
addHandler(packagesLogger)

proc fetchPackages* =
  packagesLogger.log lvlAll, "Fetching packages.."
  let resp = getContent("https://raw.githubusercontent.com/nim-lang/packages/master/packages.json")

  packageNodes = seq[JsonNode](@[])
  for node in parseJson($resp).items:
    packageNodes.add node

  writeFile("packages.json", $resp)

proc initPolling* {.async.} =
  while true:
    # supposed to be once every 24h
    await sleepAsync 24 * 600 * 10000
    fetchPackages()

proc searchInPackages*(keyword: string): JsonNode =
  packagesLogger.log(lvlAll, "Searching with keyword: " & keyword)
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

  packagesLogger.log lvlAll, "Returning a response: " & $response
  return response