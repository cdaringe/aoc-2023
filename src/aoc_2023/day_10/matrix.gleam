import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/result
import gleam/io
import gleam/bool
import gleam/int
import gleam/set

pub type Matrix(a) =
  List(List(a))

pub fn of_lines(lines: List(String), parse_cell: fn(String) -> a) -> Matrix(a) {
  list.map(
    lines,
    fn(line) {
      string.split(line, "")
      |> list.map(parse_cell)
    },
  )
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type CoordVal(a) {
  CoordVal(coord: Coord, val: a)
}

// pub fn coord_to_string(c: Coord) {
//   "(" <> int.to_string(c.0) <> ", " <> int.to_string(c.1) <> ")"
// }

// pub fn print_coord(c: Coord) {
//   io.println(coord_to_string(c))
// }

pub fn get_cell(matrix: Matrix(a), coord: Coord) -> Result(a, Nil) {
  let Coord(x: x, y: y) = coord
  let maybe_row = list.at(matrix, y)
  let maybe_cell = result.try(maybe_row, fn(row) { list.at(row, x) })
  maybe_cell
}

pub fn find_cell(
  matrix: Matrix(a),
  test_fn: fn(a) -> Bool,
) -> Result(CoordVal(a), Nil) {
  matrix
  |> list.index_fold(
    from: Error(Nil),
    with: fn(found, row, ry) {
      use <- bool.guard(when: result.is_ok(found), return: found)
      use found, val, ri <- list.index_fold(row, Error(Nil))
      use <- bool.guard(when: result.is_ok(found), return: found)
      case test_fn(val) {
        False -> Error(Nil)
        _ -> Ok(CoordVal(coord: Coord(y: ry, x: ri), val: val))
      }
    },
  )
}

const adjacency_dirs = [#(-1, 0), #(0, -1), #(0, 1), #(1, 0)]

pub fn get_neighbor_if(
  matrix: Matrix(a),
  coord: Coord,
  test: fn(CoordVal(a)) -> Bool,
) -> Result(CoordVal(a), Nil) {
  use dir <- list.find_map(adjacency_dirs)
  let #(dx, dy) = dir
  let candidate = Coord(x: coord.x + dx, y: coord.y + dy)
  case get_cell(matrix, candidate) {
    Ok(neighbor) -> {
      let cv = CoordVal(coord: candidate, val: neighbor)
      case test(cv) {
        True -> Ok(cv)
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}
