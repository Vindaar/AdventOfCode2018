import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath
import options

func sliceToNum[T](s: seq[T]): int =
  for i in countdown(s.high, 0):
    result += s[^(i + 1)].int * 10 ^ i

func pickNewRecipe[T: SomeInteger](elf: var int, recipes: seq[T]) =
  let elfVal = recipes[elf]
  let numRecipes = recipes.len
  let steps = elfVal + 1
  elf = (elf + steps.int) mod numRecipes

func makeRecipes(num: int): int =
  var recipes = newSeqOfCap[int](num + 10)
  recipes.add @[3, 7]
  var
    elf1 = 0
    elf2 = 1
  while recipes.len < num + 10:
    debugecho "num recipes: ", recipes.len
    let new = recipes[elf1] + recipes[elf2]
    let one = new div 10
    let zero = new mod 10
    if one > 0:
      recipes.add @[one, zero]
    else:
      recipes.add zero
    elf1.pickNewRecipe(recipes)
    elf2.pickNewRecipe(recipes)
  result = sliceToNum(recipes[num .. num + 9])

func numDigits(num: int): int =
  var powerTen = 1
  result = 0
  while num > powerTen:
    inc result
    powerTen *= 10

func match(recipes: seq[uint8], num, nDigits: int): bool =
  sliceToNum(recipes[^nDigits .. ^1]) == num

func recipesToLeft(num: int): int =
  var recipes = newSeqOfCap[uint8](100_000_000)
  recipes.add @[3'u8, 7]
  var
    elf1 = 0
    elf2 = 1
    nDigits = num.numDigits
  var count = 0
  while recipes.len < nDigits or not match(recipes, num, nDigits):
    let new = recipes[elf1] + recipes[elf2]
    let one = (new div 10).uint8
    let zero = (new mod 10).uint8
    if one > 0'u8:
      recipes.add one
      if match(recipes, num, nDigits):
        break
    recipes.add zero
    elf1.pickNewRecipe(recipes)
    elf2.pickNewRecipe(recipes)
    inc count
  result = recipes.len - nDigits

proc main =
  let test1 = makeRecipes(9)
  echo "Test1 = ", test1
  doAssert test1 == 5158916779

  let test2 = makeRecipes(5)
  echo "Test2 = ", test2
  doAssert test2 == 0124515891

  let test3 = makeRecipes(18)
  echo "Test3 = ", test3
  doAssert test3 == 9251071085

  let test4 = makeRecipes(2018)
  echo "Test4 = ", test4
  doAssert test4 == 5941429882

  let p1Res = makeRecipes(320851)
  echo "Part1 = ", p1Res

  let test1P2 = recipesToLeft(51589)
  echo "Test1P2 = ", test1P2
  doAssert test1P2 == 9

  let test3P2 = recipesToLeft(92510)
  echo "Test3P2 = ", test3P2
  doAssert test3P2 == 18

  let test4P2 = recipesToLeft(59414)
  echo "Test4P2 = ", test4P2
  doAssert test4P2 == 2018

  let p2Res = recipesToLeft(320851)
  echo "Part2 = ", p2Res

when isMainModule:
  main()
