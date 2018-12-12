import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath

const HeaderPrefix = "initial state: "
const LinesTmpl = "$+ => $+"

const tests = """
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
"""

const testRes = """
...#..#.#..##......###...###...........
...#...#....#.....#..#..#..#...........
...##..##...##....#..#..#..##..........
..#.#...#..#.#....#..#..#...#..........
...#.#..#...#.#...#..#..##..##.........
....#...##...#.#..#..#...#...#.........
....##.#.#....#...#..##..##..##........
...#..###.#...##..#...#...#...#........
...#....##.#.#.#..##..##..##..##.......
...##..#..#####....#...#...#...#.......
..#.#..#...#.##....##..##..##..##......
...#...##...#.#...#.#...#...#...#......
...##.#.#....#.#...#.#..##..##..##.....
..#..###.#....#.#...#....#...#...#.....
..#....##.#....#.#..##...##..##..##....
..##..#..#.#....#....#..#.#...#...#....
.#.#..#...#.#...##...#...#.#..##..##...
..#...##...#.#.#.#...##...#....#...#...
..##.#.#....#####.#.#.#...##...##..##..
.#..###.#..#.#.#######.#.#.#..#.#...#..
.#....##....#####...#######....#.#..##.
"""

proc removePrefix(s: string, p: string): string =
  result = s
  result.removePrefix(p)

proc parseInput(s: seq[string]): (string, Table[string, string]) =
  result[0] = s[0].removePrefix(HeaderPrefix)
  result[1] = initTable[string, string]()
  for i in 2 .. s.high:
    var
      initial: string
      final: string
    if scanf(s[i], LinesTmpl, initial, final):
      result[1][initial] = $s[i][^1]

proc evolve(initial: string, steps: Table[string, string],
            nGenerations = 20'i64): int64 =
  const size = 300
  var potState: array[-size .. size, char]
  for i, x in potState:
    if i >= 0 and i < initial.len:
      potState[i] = initial[i]
    else:
      potState[i] = '.'

  var knownStates = initTable[string, int64]()
  var toBreak = false
  var
    startIdx: int
    stopIdx: int
    v: string
  for i in 1 .. nGenerations:
    var newPot = potState
    startIdx = potState.find('#') - 3 - size
    stopIdx = size - potState.reversed.find('#')
    v = potState[startIdx .. stopIdx].foldl($a & $b, "")    
    if v in knownStates:
      if knownStates[v] == i - 1:
        toBreak = true
        break
    for j in startIdx .. size - 4:
      let view = potState[j .. j + 4].foldl($a & $b, "")
      if steps.hasKey(view):
        newPot[j + 2] = steps[view][0]
      else:
        newPot[j + 2] = '.'
    potState = newPot
    knownStates[v] = i
    #doAssert potState[-3 .. testPots[i + 1].high - 3].foldl($a & $b, "") == testPots[i + 1], " i failed " & $i

  # now dry evolve by right shifting
  let toAdd = (nGenerations - knownStates[v]).int64
  for i, x in potState:
    if x == '#':
      if not toBreak:
        result += i
      else:
        result += i.int64 + toAdd
  
  
proc main =
  let lines = tests.strip.splitLines.parseInput
  echo evolve(lines[0], lines[1])

  let file = readFile("day12.txt").strip.splitLines.parseInput
  echo "Part1 = ", evolve(file[0], file[1])
  echo "Part2 = ", evolve(file[0], file[1], nGenerations = 50000000000)  
  

when isMainModule:
  main()
