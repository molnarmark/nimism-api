import asyncdispatch, httpclient, json, strutils, tables
import filters
import logging

var packageNodes* = seq[JsonNode](@[])
var searchCache* = newTable[string, string]()
var packagesLogger = newFileLogger("packages.log", fmtStr = verboseFmtStr)
addHandler(packagesLogger)

# this is only for github only at the moment
proc getReadme*(url: string): string =
  for ext in ["md", "markdown", "rks"]:
    try:
      result = getContent("https://raw.githubusercontent.com" & url.replace("https://github.com", "") & "/master/README." & ext)
      break
    except:
      continue

proc getPackageDetails*(keyword: string): JsonNode =
  result = newJObject()
  var url = searchCache[keyword]
  if url == nil:
    return

  var readme = getReadme(url)
  result.add "readme", newJString(readme)

proc fetchPackages* =
  packagesLogger.log lvlAll, "Fetching packages.."
  let resp = getContent("https://raw.githubusercontent.com/nim-lang/packages/master/packages.json")

  packageNodes = seq[JsonNode](@[])
  for node in parseJson($resp).items:
    packageNodes.add node
    searchCache.add node["name"].str.replace("\""), node["url"].str.replace("\"", "")

  writeFile("packages.json", $resp)

proc initPolling* {.async.} =
  while true:
    fetchPackages()
    # supposed to be once every 24h
    await sleepAsync 24 * 600 * 10000

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