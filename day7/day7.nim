import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath, arraymancer

const test1 = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""

type
  Worker = object
    step: char
    busy: bool
    done: bool
    tremain: int

proc parseSteps(file: seq[string]): Table[char, set[char]] =
  var
    step1: string
    step2: string
  result = initTable[char, set[char]]()
  for l in file:
    if scanf(l, "Step $* must be finished before step $* can begin.", step1, step2):
      if result.hasKey(step2[0]):
        result[step2[0]].incl step1[0]
      else:
        result[step2[0]] = {step1[0]}
  # create start point
  var keys: set[char]
  var vals: set[char]
  for k, v in result:
    keys.incl k
    vals.incl v
  for v in vals:
    if v notin keys:
      result[v] = {}

proc getAvailable(tab: Table[char, set[char]], workedOn: set[char] = {}): seq[char] =
  for k, v in tab:
    if k notin workedOn and v.card == 0:
      result.add k
  result.sort(SortOrder.Descending)

proc update(tab: var Table[char, set[char]], s: char, workedOn: set[char]): seq[char] =
  # delete key
  tab.del(s)
  # find requirement `s` in all other steps
  for k, v in mpairs(tab):
    if s in v:
      v.excl(s)
  # now find new first
  result = getAvailable(tab, workedOn)

proc workedOn(workers: seq[Worker]): set[char] =
  for w in workers:
    if w.step.ord > 60:
      result.incl w.step

proc walkGraphP2(t: Table[char, set[char]]): int =
  var tab = t
  var cand = getAvailable(tab)
  var workers = newSeq[Worker](5)
  var res = ""
  while tab.len > 0:
    for w in mitems(workers):
      if w.busy:
        w.tremain -= 1
        if w.tremain == 0:
          w.done = true
          w.busy = false

    for w in mitems(workers):
      if w.done:
        res.add w.step
        let current = workers.workedOn
        cand = update(tab, w.step, current)
        w.done = false
        w.step = '0'

    var i = 0
    for w in mitems(workers):
      if not w.done and not w.busy and cand.len > 0:
        w.step = cand.pop
        w.tremain = 60 + ord(w.step) - 64
        w.busy = true
      inc i
    if tab.len > 0:
      # if done, don't increase time
      inc result
  echo "Order in part 2: ", res

proc getNext(tab: Table[char, set[char]]): char =
  let cand = getAvailable(tab)
  if cand.len > 0:
    result = min(cand)

proc updateTab(tab: var Table[char, set[char]], s: var char) =
  # delete key
  tab.del(s)
  # find requirement `s` in all other steps
  for k, v in mpairs(tab):
    if s in v:
      v.excl(s)
  # now find new first
  s = getNext(tab)

proc walkGraph(t: Table[char, set[char]]): string =
  var tab = t
  var next = getNext(tab)
  while tab.len > 0:
    result.add next
    updateTab(tab, next)

proc main =
  let file = readFile("day7.txt").strip.splitLines

  let t = test1.strip.splitLines.parseSteps.walkGraph
  echo t
  doAssert t == "CABDFE"
  echo "Part1 = ", file.parseSteps.walkGraph

  echo "Part2 = ", file.parseSteps.walkGraphP2


when isMainModule:
  main()
