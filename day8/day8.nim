import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath, arraymancer

const test1 = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

type
  Node = object
    name: int
    children: seq[Node]
    metadata: seq[int]

proc `$`(n: Node): string =
  result = "[name: " & $n.name & ", children: " & $n.children & ", metadata: " & $n.metadata & "]"

proc parseNode(data: seq[string], idx: var int): Node =
  var name {.global.} = 0
  result.name = name
  inc name
  # parse header
  let numNodes = data[idx].parseInt
  inc idx
  let numMeta = data[idx].parseInt
  inc idx
  # parse nodes
  for j in 0 ..< numNodes:
    result.children.add parseNode(data, idx)
  # parse metadata
  for j in 0 ..< numMeta:
    let val = data[idx].parseInt
    result.metadata.add val
    inc idx

proc calcSumMeta(n: Node): int =
  for c in n.children:
    result += c.calcSumMeta
  if n.metadata.len > 0:
    result += n.metadata.foldl(a + b)

proc parseNodes(data: string): Node =
  let cmds = data.splitWhitespace
  var i = 0
  result = parseNode(cmds, i)

proc calcRootValue(n: Node): int =
  for m in n.metadata:
    if m <= n.children.len:
      result += n.children[m - 1].calcRootValue
  if n.children.len == 0:
    result += n.metadata.foldl(a + b)

proc main =
  let file = readFile("day8.txt").strip

  let testNodes = test1.strip.parseNodes
  let t = testNodes.calcSumMeta
  echo t
  echo testNodes
  doAssert t == 138
  echo "Part1 = ", file.parseNodes.calcSumMeta

  echo testNodes.calcRootValue
  echo "Part2 = ", file.parseNodes.calcRootValue


when isMainModule:
  main()
