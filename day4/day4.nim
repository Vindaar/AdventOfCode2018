import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath

const test1 = """
"""

const test2 = """
"""
const timeStr = "yyyy-MM-dd hh:mm"

type
  GuardKind = enum
    gkWake, gkSleep, gkStart

  Sleep = object
    start: int
    stop: int

  Guard = object
    shifts: int
    sleepStarts: seq[int]
    sleepStops: seq[int]

proc getGuardKind(line: string): GuardKind =
  case line[19]
  of 'G':
    result = gkStart
  of 'w':
    result = gkWake
  of 'f':
    result = gkSleep
  else: discard

proc parseGuards(file: seq[string]): Table[int, Guard] =
  var
    dateStr = ""
    gTab = initTable[int, Guard]()
    dates: seq[(int, DateTime)]

  for i, l in file:
    dateStr = l[1 .. 16]
    let date = dateStr.parse(timeStr)
    dates.add (i, date)
    
  # sort dates
  let sortedDates = dates.sortedByIt(it[1])
  var guardId = 0
  for tup in sortedDates:
    let
      i = tup[0]
      d = tup[1]
    # get correct line
    let line = file[i]
    let gkind = getGuardKind(line)
    case gkind
    of gkWake:
      gTab[guardId].sleepStops.add d.minute
    of gkSleep:
      gTab[guardId].sleepStarts.add d.minute
    of gkStart:
      var
        id = 0
        dummy = ""
      if scanf(line, "$*#$i", dummy, id):
        guardId = id
        if gTab.hasKey(guardId):
          gTab[guardId].shifts += 1
        else:
          gTab[guardId] = Guard(shifts: 1)
  result = gTab

proc findMostSleeping(gTab: Table[int, Guard]): int =
  var sleeps: seq[(int, int)]
  for k, g in gTab:
    if g.sleepStarts.len > 0:
      let sleep = zip(g.sleepStarts, g.sleepStops).mapIt(it[1] - it[0]).foldl(a + b)
      sleeps.add (k, sleep)
  let sorted = sleeps.sortedByIt(it[1])
  result = sorted[^1][0]

iterator sleepingMinutes(g: Guard): int =
  let sleepZip = zip(g.sleepStarts, g.sleepStops)
  for tup in sleepZip:
    let
      start = tup[0]
      stop = tup[1]
    let r = toSeq(start ..< stop)
    for x in r:
      yield x

proc mostSleptMinute(g: Guard): int =
  var sleeps: array[60, int]
  for x in sleepingMinutes(g):
    sleeps[x] += 1
  result = argmax(sleeps)

proc sleepsInMinute(g: Guard, minute: int): int =
  for x in sleepingMinutes(g):  
    if x == minute:
      inc result

proc mostSleptMinute(gTab: Table[int, Guard]): (int, int) =
  var minuteGuard: seq[(int, int)]
  var sleeps: seq[int]
  for k, g in gTab:
    let minute = mostSleptMinute(g)
    let nSleep = sleepsInMinute(g, minute)
    minuteGuard.add (k, minute)
    sleeps.add nSleep
  let idx = argmax(sleeps)
  result = minuteGuard[idx]    
  
proc dostuff1(file: seq[string]): int =
  discard

proc dostuff2(file: seq[string]): int =
  discard

proc main =
  let file = readFile("day4.txt").strip.splitLines

  let gTab = file.parseGuards
  let guard = gTab.findMostSleeping
  let minute = mostSleptMinute(gTab[guard])
  echo "Part1 = ", guard * minute
  let minuteGuard = mostSleptMinute(gTab)
  echo "Part2 = ", minuteGuard[0] * minuteGuard[1]
  
  # echo file.dostuff2


when isMainModule:
  main()
