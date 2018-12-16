import strutils, sequtils, sugar, os, sets, tables, strscans, times, algorithm, typetraits, seqmath
import options
import heapqueue

const tests1 = """
/->-\
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
  \------/
"""

const tests2 = """
/>-<\
|   |
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/
"""

type
  DirectionKind = enum
    none = ""
    left = "<"
    right = ">"
    up = "^"
    down = "v"

  RawDirection = enum
    u, l, d, r

  FieldKind = enum
    empty = " "
    intersection = "+"
    horizontal = "-"
    cornerRight = "/"
    cornerLeft = "\\"
    vertical = "|"

  IntersectionKind = enum
    turnLeft, goStraight, turnRight

  Cart = object
    direction: DirectionKind
    position: tuple[x, y: int]
    nextInterDir: IntersectionKind

  Grid[N: static int] = array[N, array[N, FieldKind]]

  GridString[N: static int] = array[N, string]

proc parseGrid[N: static int](s: seq[string]): (Grid[N], seq[Cart]) =
  var carts = newSeq[Cart]()
  var grid: Grid[N]
  for iy, y in s:
    for ix, el in y:
      let dir = parseEnum[DirectionKind]($el, none)
      case dir
      of left:
        carts.add Cart(direction: left,
                       position: (x: ix, y: iy),
                       nextInterDir: turnLeft)
        grid[iy][ix] = horizontal
      of right:
        carts.add Cart(direction: right,
                       position: (x: ix, y: iy),
                       nextInterDir: turnLeft)
        grid[iy][ix] = horizontal
      of up:
        carts.add Cart(direction: up,
                       position: (x: ix, y: iy),
                       nextInterDir: turnLeft)
        grid[iy][ix] = vertical
      of down:
        carts.add Cart(direction: down,
                       position: (x: ix, y: iy),
                       nextInterDir: turnLeft)
        grid[iy][ix] = vertical
      of none:
        let field = parseEnum[FieldKind]($el, empty)
        grid[iy][ix] = field
  result = (grid, carts)

func `<`(c1, c2: Cart): bool =
  if c1.position.y < c2.position.y:
    result = true
  elif c1.position.y == c2.position.y and
       c1.position.x < c2.position.x:
    result = true
  else:
    result = false

# pretty printing of grid, cart
func `$`(c: Cart): string =
  result = "Dir: " & $c.direction & ", at: (" & $c.position.x &
    " / " & $c.position.y & "), nextInt: " & $c.nextInterDir

func `$`[N](g: Grid[N] | GridString[N]): string =
  for row in g:
    if not row.allIt($it == $empty):
      for el in row:
        result &= $el
      result &= "\n"

proc echoGrid[N](grid: Grid[N], carts: seq[Cart]): string =
  var gridC: GridString[N]
  for iy, y in grid:
    gridC[iy] = newStringOfCap(y.len)
    for ix, x in y:
      gridC[iy].add ($x)[0]

  for c in carts:
    let (x, y) = c.position
    let curField = parseEnum[FieldKind]($gridC[y][x], empty)
    case curField
    of empty:
      # means cart is on it already, crash
      gridC[y][x] = 'X'
    else:
      # valid field
      gridC[y][x] = ($c.direction)[0]

  result = $gridC

proc makeQueue(carts: seq[Cart]): HeapQueue[Cart] =
  for c in carts:
    result.push c

func toRawDir(dir: DirectionKind): RawDirection =
  case dir
  of up: result = u
  of left: result = l
  of down: result = d
  of right: result = r
  else: discard

func toDir(rdir: RawDirection): DirectionKind =
  case rdir
  of u: result = up
  of l: result = left
  of d: result = down
  of r: result = right
  else: discard

proc decrease[T: enum](val: T): T =
  if val > T.low:
    result = T(ord(val) - 1)
  else:
    result = T.high

proc increase[T: enum](val: T): T =
  if val < T.high:
    result = T(ord(val) + 1)
  else:
    result = T.low

proc turn(c: var Cart) =
  let rDir = c.direction.toRawDir
  case c.nextInterDir
  of turnLeft: c.direction = (increase rDir).toDir
  of turnRight: c.direction = (decrease rDir).toDir
  else: discard
  c.nextInterDir = increase(c.nextInterDir)

proc updateDirection(c: var Cart, field: FieldKind) =
  case field
  of cornerLeft:
    case c.direction
    of up:
      c.direction = left
    of down:
      c.direction = right
    of right:
      c.direction = down
    of left:
      c.direction = up
    else: discard
  of cornerRight:
    case c.direction
    of up:
      c.direction = right
    of down:
      c.direction = left
    of right:
      c.direction = up
    of left:
      c.direction = down
    else: discard
  of intersection:
    c.turn
  of horizontal, vertical, empty:
    # direction remains unchanged
    discard

func newPosition(c: Cart): (int, int) =
  # NOTE: up and down inverted, due to y == 0 being at
  # the top!
  let (x, y) = c.position
  case c.direction
  of up:    result = (x,     y - 1)
  of right: result = (x + 1, y)
  of down:  result = (x,     y + 1)
  of left:  result = (x - 1, y)
  of none: discard

proc performTick[N](grid: Grid[N], carts: var seq[Cart],
                    part2 = false): Option[(int, int)] =
  var hQueue = makeQueue(carts)
  var cartPos = initSet[(int, int)]()
  # add all carts in tail
  for i in 0 ..< hQueue.len:
    cartPos.incl hQueue[i].position

  while hQueue.len > 0:
    var c = hQueue.pop
    let idx = carts.find(c)
    if idx < 0:
      continue
    let (x, y) = c.position
    let (xNew, yNew) = c.newPosition
    # update position
    c.position = (xNew, yNew)
    # now update direction of cart
    c.updateDirection(grid[yNew][xNew])
    # update carts
    carts[idx] = c
    if c.position notin cartPos:
      cartPos.incl c.position
    else:
      carts.keepItIf(it.position != c.position)
      if not part2:
        return some(c.position)

    # finally remove old position from cartPos
    cartPos.excl (x, y)

  if carts.len == 1:
    result = some(carts[0].position)

template run(size: static int, input: untyped, p2 = false): untyped =
  var (grid, carts) = parseGrid[size](input.splitLines)
  var res: Option[(int, int)]
  while isNone(res):
    res = grid.performTick(carts, p2)
    # echo echoGrid(grid, carts)
  res

proc main =
  let testRes = run(13, tests1)
  echo "Test crash at ", testRes

  let p1Res = run(150, readFile("day13.txt"))
  echo "Part1 crash at ", p1Res

  let test2Res = run(13, tests2, p2 = true)
  echo "Test2 crash at ", test2Res

  let p2Res = run(150, readFile("day13.txt"), p2 = true)
  echo "Part2 crash at ", p2Res

when isMainModule:
  main()
