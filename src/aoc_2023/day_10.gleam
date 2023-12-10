import aoc_2023/common
import aoc_2023/day_10/matrix
import gleam/list
import gleam/bool
import gleam/iterator
import gleam/io

type Pipe {
  HBar
  VBar
  TR
  TL
  BL
  BR
  Start
  Hole
}

type PipeGrid =
  matrix.Matrix(Pipe)

type CVP =
  matrix.CoordVal(Pipe)

pub fn pt_1(input: String) {
  let grid: PipeGrid =
    input
    |> parse
  let assert Ok(s) = matrix.find_cell(grid, fn(v) { v == Start })
  build_loop(grid, s)
  |> list.length
  |> fn(x) { x / 2 }
}

pub fn pt_2(input: String) {
  todo
}

fn parse(input: String) -> PipeGrid {
  input
  |> common.lines
  |> matrix.of_lines(parse_pipe)
}

fn nav(m: PipeGrid, last: CVP, current: CVP) -> CVP {
  matrix.get_neighbor_if(
    m,
    current.coord,
    fn(neighb: CVP) {
      use <- bool.guard(
        when: last.coord.x == neighb.coord.x && last.coord.y == neighb.coord.y,
        return: False,
      )
      can_connect(current, neighb)
    },
  )
  |> common.expect("no neighbor found")
}

fn build_loop(matrix: PipeGrid, start: CVP) -> List(CVP) {
  iterator.from_list([1])
  |> iterator.cycle
  |> iterator.fold_until(
    from: [start],
    with: fn(coords: List(CVP), _) {
      let #(curr, last) = case coords {
        [] -> panic as "bummer"
        [x] -> #(x, x)
        [x, y, ..] -> #(x, y)
      }
      let next = nav(matrix, last, curr)
      case next.val {
        Start -> list.Stop(coords)
        _ -> list.Continue([next, ..coords])
      }
    },
  )
}

type Dir {
  Up
  Right
  Down
  Left
}

fn get_dir(p1: CVP, p2: CVP) {
  let dx = p2.coord.x - p1.coord.x
  let dy = p2.coord.y - p1.coord.y
  case dx, dy {
    1, _ -> Right
    _, 1 -> Down
    -1, _ -> Left
    _, -1 -> Up
    _, _ -> panic
  }
}

fn has_mate(pipe: Pipe, dir: Dir) {
  case pipe, dir {
    Start, _ -> True
    HBar, Left -> True
    HBar, Right -> True
    VBar, Up -> True
    VBar, Down -> True
    TL, Right -> True
    TL, Down -> True
    TR, Left -> True
    TR, Down -> True
    BR, Left -> True
    BR, Up -> True
    BL, Right -> True
    BL, Up -> True
    _, _ -> False
  }
}

fn invert_dir(dir: Dir) {
  case dir {
    Up -> Down
    Left -> Right
    Right -> Left
    Down -> Up
  }
}

fn can_connect(p1: CVP, p2: CVP) {
  io.debug(#("connect_check?", p1.val, p2.val))
  let dir = get_dir(p1, p2)
  let m1 = has_mate(p1.val, dir)
  let m2 = has_mate(p2.val, invert_dir(dir))
  let ok = m1 && m2 && m1 == m2
  io.debug(#(" ", ok, p1.val, dir, p2.val))
  ok
}

fn parse_pipe(it: String) -> Pipe {
  case it {
    "-" -> HBar
    "|" -> VBar
    "F" -> TL
    "7" -> TR
    "J" -> BR
    "L" -> BL
    "." -> Hole
    "S" -> Start
    _ -> panic as "bad pipe part"
  }
}
