import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath

const test1 = "dabAcCaCBAcCcaDA"

proc toRemove(data: string, x: char, pos: int, capital: bool): (bool, char) =
  let t = data[pos + 1]
  if not capital:
    result = if t == char(ord(x) - 32): (true, t) else: (false, t)
  else:
    result = if t == char(ord(x) + 32): (true, t) else: (false, t)

proc dostuff1(file: string): string =
  var data = file
  var i = 0
  var remove = false
  var pos = 0
  var t = '0'
  while i < data.high:
    t = data[i]
    pos = i
    if i < data.high:
      let capital = ord(t) < 97
      (remove, t) = toRemove(data, t, i, capital)
      if remove:
        data.delete(i, i + 1)
        dec i, 2
    inc i
  result = data

proc dostuff2(data: string): int =
  # remove all pairs
  var lengths: seq[int]
  var mdata = data
  for x in {'a' .. 'z'}:
    mdata = data.multireplace(($x, "")).multireplace(($(char(ord(x) - 32)), ""))
    let new = mdata.dostuff1
    lengths.add new.len
  result = min(lengths)

proc main =
  let file = readFile("day5.txt").strip

  echo "Part1 = ", file.dostuff1.len

  echo test1.strip.dostuff1

  echo "Part2 = ", file.dostuff2
  echo test1.dostuff2


when isMainModule:
  main()
