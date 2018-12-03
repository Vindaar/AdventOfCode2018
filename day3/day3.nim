import strutils, sequtils, sugar, os, sets, tables, strscans

const test1 = """
"""

const test2 = """
#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
"""

type
  Rectangle = object
    id: int
    x: int
    y: int
    width: int
    height: int

proc getRectangles(file: seq[string]): seq[Rectangle] =
  var
    id: int
    x: int
    y: int
    w: int
    h: int
  for l in file:
    if scanf(l, "#$i @ $i,$i: $ix$i", id, x, y, w, h):
      result.add Rectangle(id: id, x: x, y: y, width: w, height: h)

iterator positions(r: Rectangle): (int, int) =
  for xi in 0 ..< r.width:
    for yi in 0 ..< r.height:
      let xpos = r.x + xi
      let ypos = r.y + yi
      yield (xpos, ypos)

proc getFtab(rects: seq[Rectangle]): Table[(int, int), int] =
  result = initTable[(int, int), int]()
  for r in rects:
    for xi, yi in positions(r):
      if not result.hasKey((xi, yi)):
        result[(xi, yi)] = 1
      else:
        result[(xi, yi)] += 1

proc dostuff1(ftab: Table[(int, int), int]): int =
  for k, v in ftab:
    if v > 1:
      inc result

proc dostuff2(rects: seq[Rectangle], ftab: Table[(int, int), int]): int =
  for r in rects:
    var unique = true
    for xi, yi in positions(r):
      if ftab[(xi, yi)] > 1:
        unique = false
        break
    if unique:
      result = r.id

proc main =
  let file = readFile("day3.txt").strip.splitLines

  let rects = file.getRectangles
  let ftab = rects.getFtab
  echo ftab.dostuff1

  let rectTest2 = test2.strip.splitLines.getRectangles
  let ftabTest2 = rectTest2.getFtab
  echo rectTest2.dostuff2(ftabTest2)
  echo dostuff2(rects, ftab)


when isMainModule:
  main()
