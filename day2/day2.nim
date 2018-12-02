import strutils, sequtils, sugar, os, sets, tables
import zero_functional

const test1 = """
abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab
"""

const test2 = """
abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz
"""

proc dostuff1(file: seq[string]): int =

  var restab = initTable[int, int]()
  var checksum = 0
  for l in file:
    var xtab = initTable[char, int]()
    for x in l:
      if xtab.hasKey(x):
        xtab[x] += 1
      else:
        xtab[x] = 1
    var interset = initSet[int]()
    for x, y in xtab:
      interset.incl y
    for y in interset:
      if y != 1:
        if restab.hasKey(y):
          restab[y] += 1
        else:
          restab[y] = 1

  result = 1
  for x, y in restab:
    result *= y

proc dostuff2(file: seq[string]): string =

  let llen = file[0].len
  for xl in file:
    for yl in file:
      var diff = ""
      var wrong = 0
      for i in 0 ..< llen:
        if xl[i] == yl[i]:
          diff.add xl[i]
        else:
          inc wrong
          if wrong > 1:
            break
      if wrong == 1:
        return diff


proc main =
  let file = readFile("day2.txt").splitLines.filterIt(it.len > 0)

  echo test1.splitLines.dostuff1
  echo file.dostuff1

  echo test2.splitLines.filterIt(it.len > 0).dostuff2
  echo file.dostuff2

when isMainModule:
  main()
