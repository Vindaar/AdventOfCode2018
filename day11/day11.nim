import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath

func getRackId(x: int): int = x + 10

proc calcPowerLevel(x, y: int, serialNumber: int): int =
  result = getRackId(x) * y
  result += serialNumber
  result = result * getRackId(x)
  result = (result div 100) mod 10
  dec result, 5

func calcGridVal(x, y: int, grid: array[1 .. 300, array[1 .. 300, int]],
                 gridSize = 3): int =
  for ix in x .. x + gridSize - 1:
    for iy in y .. y + gridSize - 1:
      inc result, grid[ix][iy]

func findLargestGrid(grid: array[1 .. 300, array[1 .. 300, int]],
                     gridSize = 3): ((int, int), int) =
  var maxGrid: int
  var maxCoord: tuple[x, y: int]
  for x in 1 .. (300 - gridSize + 1):
    for y in 1 .. (300 - gridSize + 1):
      let gridVal = calcGridVal(x, y, grid, gridSize)
      if gridVal > maxGrid:
        maxGrid = gridVal
        maxCoord = (x, y)
  result = (maxCoord, maxGrid)

func findLargestGridAnySize(grid: array[1 .. 300, array[1 .. 300, int]]): (int, int, int) =
  var maxGrid: int
  for size in 1 .. 300:
    let largestGrid = findLargestGrid(grid, size)
    if largestGrid[1] > maxGrid:
      maxGrid = largestGrid[1]
      result = (largestGrid[0][0], largestGrid[0][1], size)

func calcFullGrid(serialNumber: int): array[1 .. 300, array[1 .. 300, int]] =
  for x in 1 .. 300:
    for y in 1 .. 300:
      result[x][y] = calcPowerLevel(x, y, serialNumber)
  
func runTest =
  doAssert calcPowerLevel(3, 5, 8) == 4, " was " & $calcPowerLevel(3, 5, 8)
  doAssert calcPowerLevel(122, 79, 57) == -5, " was " & $calcPowerLevel(122, 79, 57)
  doAssert calcPowerLevel(217, 196, 39) == 0, " was " & $calcPowerLevel(217, 196, 39)
  doAssert calcPowerLevel(101, 153, 71) == 4, " was " & $calcPowerLevel(101, 153, 71)
  
  const serialNumber1 = 18
  let grid1 = calcFullGrid(serialNumber1)
  doAssert findLargestGrid(grid1)[0] == (33, 45)
  #let largestAnyGrid1 = findLargestGridAnySize(grid1)
  #doAssert largestAnyGrid1 == (90, 269, 16), $largestAnyGrid1
  const serialNumber2 = 42
  let grid2 = calcFullGrid(serialNumber2)
  doAssert findLargestGrid(grid2)[0] == (21, 61)
  #let largestAnyGrid2 = findLargestGridAnySize(grid2)  
  #doAssert largestAnyGrid2 == (232,251,12), $largestAnyGrid2

proc runParts =
  const serialNumber = 7857
  let grid = calcFullGrid(serialNumber)
  let part1 = findLargestGrid(grid)[0]
  echo "Part1 = ", part1

  echo "Part2 = ", findLargestGridAnySize(grid)
  
proc main =

  runTest()
  runParts()

when isMainModule:
  main()
