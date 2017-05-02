import json, strutils, sequtils, logging

var filtersLogger = newFileLogger("filters.log", fmtStr = verboseFmtStr)
addHandler(filtersLogger)

type
  SearchFilter = object
    kind: string
    value: string

proc isFilter*(s: string): bool = "=" in s
proc isMultiFilter*(s: string): bool = ";" in s

proc apply(filter: SearchFilter, packages: seq[JsonNode]): JsonNode

proc applyFilters*(filters: seq[SearchFilter], packages: seq[JsonNode]): JsonNode =
  var result = newJArray()
  echo filters.len
  for filter in filters:
    result = filter.apply(packages)

  return result

proc apply(filter: SearchFilter, packages: seq[JsonNode]): JsonNode =
  var result = newJArray()
  var pkgResult = seq[JsonNode](@[])
  let kind = filter.kind
  let value = filter.value

  case kind:
  of "repo":
    pkgResult = packages.filter(proc(package: JsonNode): bool =
      case value.normalize:
      of "github":
        return package["method"].getStr.normalize == "git"

      of "bitbucket":
        return package["method"].getStr.normalize == "hg"
      )
  of "license":
    pkgResult = packages.filter(proc(package: JsonNode): bool = package["license"].getStr.normalize == value.normalize)

  for package in pkgResult:
    result.add package

  filtersLogger.log lvlAll, "Applied a filter"
  return result

proc parseFilters*(keyword: string): seq[SearchFilter] =
  var filters = seq[SearchFilter](@[])
  var usedFilters = seq[string](@[])

  if isMultiFilter keyword:
    for filterSet in keyword.split ",":
        if filterSet == "": break
        let filterData = filterSet.split "="
        if not usedFilters.contains(filterData[0]): filters.add SearchFilter(kind: filterData[0], value: filterData[1])
        usedFilters.add filterData[0]
  else:
    let filterData = keyword.split "="
    if not usedFilters.contains(filterData[0]): filters.add SearchFilter(kind: filterData[0], value: filterData[1])
    usedFilters.add filterData[0]

  return filters