import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath, arraymancer
import plotly

const ScanTmpl = "position=<$s$i, $s$i> velocity=<$s$i, $s$i>"

const tests = """
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
"""

type
  Point = object
    x: int
    y: int
    vx: int
    vy: int

proc parseInput(s: seq[string]): seq[Point] =
  var
    x: int
    y: int
    vx: int
    vy: int
  for l in s:
    if scanf(l, ScanTmpl, x, y, vx, vy):
      result.add Point(x: x, y: y, vx: vx, vy: vy)

func propagatePoint(p: Point, t: int): Point =
  # calculates new point based velocity and delta t
  result = Point(x: p.x + p.vx * t,
                 y: p.y + p.vy * t,
                 vx: p.vx,
                 vy: p.vy)

func maxX(points: seq[Point]): int =
  for p in points:
    if p.x > result:
      result = p.x

func maxY(points: seq[Point]): int =
  for p in points:
    if p.y > result:
      result = p.y

func minX(points: seq[Point]): int =
  for p in points:
    if p.x < result:
      result = p.x

func minY(points: seq[Point]): int =
  for p in points:
    if p.y < result:
      result = p.y

proc `$`(points: seq[Point]) =
  ## string representation of the grid
  let maxX = points.maxX + 10
  let maxY = points.maxY + 10
  var zs = newSeq[int](maxX * maxY).reshape2D([maxX, maxY])
  for p in points:
    let
      y = p.y + 5
      x = p.x + 5
    zs[x][y] = 1
  heatmap(zs).show()

proc diff(points: seq[Point]): (int, int) =
  ## return max difference in X and Y of all points
  let
    minX = points.minX
    minY = points.minY
    maxX = points.maxX
    maxY = points.maxY
  result = (maxX - minX, maxY - minY)

proc echoResult(points: seq[Point], outfile: string) =
  var diffs: seq[int]
  var t = 0
  while true:
    let newPoints = points.mapIt(it.propagatePoint(t))
    diffs.add (newPoints.diff[0] + newPoints.diff[1])
    if diffs.len > 1 and diffs[^1] > diffs[^2]:
      break
    inc t
  echo "Part2 = ", t - 1
  let res = points.mapIt(it.propagatePoint(t - 1))

proc main =
  let lines = tests.strip.splitLines.parseInput
  lines.echoResult("test1.txt")

  let file = readFile("day10.txt").strip.splitLines.parseInput
  file.echoResult("part1.txt")

when isMainModule:
  main()
