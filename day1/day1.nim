import sequtils, strutils, os
import zero_functional, sets

const test1 = """+3
+3
+4
-2
-4
"""

proc dostuff(file: seq[string]) =
  var
    freq = 0
    fSet = initSet[int]()
    p1Res = 0
    p1found = false
    i = 0  
  while true:
    let l = file[i]
    if l.len > 0:
      let f = l.parseInt
      freq += f
      if freq in fSet:
        break
      else:
        fSet.incl freq
    inc i
    if i == file.len:
      if not p1Found:
        p1Res = freq
      p1Found = true
      i = 0
      
  echo "res freq p1 ", p1Res
  echo "res freq p2 ", freq

proc main =

  let file = readFile("day1Data.txt").splitLines

  file.dostuff

  test1.splitLines().dostuff  
  
when isMainModule:
  main()
