import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath, arraymancer

const test1 = """
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
"""

proc getCoords(file: seq[string]): Table[(int, int), int] =
  result = initTable[(int, int), int]()
  var coords: seq[(int, int)]
  var x: int
  var y: int
  for l in file:
    if scanf(l, "$i, $i", x, y):
      coords.add (x, y)
  let sorted = coords.sortedByIt(it[0])
  var c = 1
  for tup in sorted:
    let (x, y) = tup
    result[(x, y)] = c
    inc c

func distance(x1, y1, x2, y2: int): int =
  result = abs(x2 - x1) + abs(y2 - y1)

proc print(tab: Table[(int, int), int], xmax, ymax: int): string =
  var ar = zeros[int](xmax + 1, ymax + 1)
  for k, v in tab:
    let (x, y) = k
    ar[x, y] = v
  result = $ar
  
proc finiteField(tab: Table[(int, int), int]): int =
  var mtab = tab
  let coords = toSeq(keys(tab))
  let xmax = coords.mapIt(it[0]).max + 1
  let ymax = coords.mapIt(it[1]).max + 1
  #echo print(tab, xmax, ymax)
  
  for x in 0 .. xmax:
    for y in 0 .. ymax:
      if (x, y) notin coords:
        var cur = newSeq[int](coords.len)
        for i, el in coords:
          cur[i] = distance(el[0], el[1], x, y)
          #echo "Curs ", cur
        let idx = argmin(cur)
        let val = tab[coords[idx]]
        if count(cur, cur[idx]) == 1:
          mtab[(x, y)] = val
        
  # filter out elements at edge of grid
  var infinite = initSet[int]()
  for k, v in mtab:
    let (x, y) = k
    if x in {0, xmax} or y in {0, ymax}:
      infinite.incl v
  echo infinite
  let vals = toSeq(values(mtab)).filterIt(it notin infinite and it > 0)
  var valSeq = newSeq[int]()
  for v in 0 .. max(vals) + 5:
    valSeq.add count(vals, v)
  echo valSeq
  result = valSeq.max

proc finiteField2(tab: Table[(int, int), int]): int =
  var mtab = tab
  let coords = toSeq(keys(tab))
  let xmax = coords.mapIt(it[0]).max + 1
  let ymax = coords.mapIt(it[1]).max + 1
  #echo print(tab, xmax, ymax)
  var regCount = 0
  for x in 0 .. xmax:
    for y in 0 .. ymax:
      var cur = newSeq[int](coords.len)
      for i, el in coords:
        cur[i] = distance(el[0], el[1], x, y)
        #echo "Curs ", cur
      let idx = argmin(cur)
      if cur.sum < 10000:
        inc regCount
        
  result = regCount
proc dostuff2(data: string): int =
  discard

proc main =
  let file = readFile("day6.txt").strip.splitLines

  echo test1.strip.splitLines.getCoords.finiteField  
  echo "Part1 = ", file.getCoords.finiteField



  echo test1.strip.splitLines.getCoords.finiteField2
  echo "Part2 = ", file.getCoords.finiteField2
  #echo test1.dostuff2


when isMainModule:
  main()
