import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath, arraymancer
import lists

const ScanTmpl = "$i players; last marble is worth $i points"
const ScanTmplTest = "$i players; last marble is worth $i points: high score is $i"

const tests = """
10 players; last marble is worth 1618 points: high score is 8317
13 players; last marble is worth 7999 points: high score is 146373
17 players; last marble is worth 1104 points: high score is 2764
21 players; last marble is worth 6111 points: high score is 54718
30 players; last marble is worth 5807 points: high score is 37305
"""

proc parseInput(s: string): (int, int) =
  if scanf(s, ScanTmpl, result[0], result[1]):
    discard

iterator parseInputTest(s: seq[string]): (int, int, int) =
  var
    players: int
    lastMarble: int
    score: int
  for l in s:
    if scanf(l, ScanTmplTest, players, lastMarble, score):
      yield (players, lastMarble, score)

func inc[T](l: var DoublyLinkedRing[T], steps = 1) =
  ## increase by `steps`
  for i in 0 ..< steps:
    l.head = l.head.next

func dec[T](l: var DoublyLinkedRing[T], steps = 1) =
  ## increase by `steps`
  for i in 0 ..< steps:
    l.head = l.head.prev

func max[T](l: DoublyLinkedRing[T]): T =
  for x in l:
    if x > result:
      result = x

proc insert[T](l: var DoublyLinkedRing[T], value: T) =
  ## inserts the given value `after` the current head
  inc l
  l.prepend(value)

proc calcHighScore(numPlayers, lastMarble: int): int =
  var players = newSeq[int](numPlayers)
  var list = initDoublyLinkedRing[int]()
  # add marble 0
  list.append(0)
  var i = 1
  while i <= lastMarble:
    for j, p in players:
      if i > lastMarble:
        break
      if i mod 23 != 0 or i == 0:
        inc list
        # append to new head
        list.insert(i)
      else:
        players[j] += i
        dec list, 7
        players[j] += list.head.value
        # remove current head
        list.remove(list.head)
        inc list
      inc i
  result = max(players)

proc main =
  let file = readFile("day9.txt").strip.parseInput
  echo file

  let lines = tests.strip.splitLines
  for t in lines.parseInputTest:
    let res = calcHighScore(t[0], t[1])
    echo res
    doAssert res == t[2]
  #echo testNodes
  echo "Part1 = ", calcHighScore(file[0], file[1])

  echo "Part2 = ", calcHighScore(file[0], file[1] * 100)


when isMainModule:
  main()
