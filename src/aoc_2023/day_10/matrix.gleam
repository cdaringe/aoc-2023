import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/result
import gleam/io
import gleam/bool
import gleam/int
import gleam/set
import aoc_2023/c/list.{find_map_index} as clist

pub type Dir {
  Up
  Right
  Down
  Left
}

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

pub fn to_string(grid: Matrix(a), cb: fn(a) -> String) -> String {
  map(grid, fn(cv) { cb(cv.val) })
  |> list.map(fn(row) { string.join(row, "") })
  |> string.join("\n")
}

pub fn map_cv(cv: CoordVal(a), cb: fn(CoordVal(a)) -> b) -> CoordVal(b) {
  CoordVal(cv.coord, val: cb(cv))
}

pub fn val_result_or(cv_res: Result(CoordVal(a), b), with fallback: a) -> a {
  case cv_res {
    Ok(cv) -> cv.val
    _ -> fallback
  }
}

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

// @warn order matters. prefer searching CW first (right, up)
// presuming leftmost edge
const adjacency_dirs = [#(0, 1), #(0, -1), #(-1, 0), #(1, 0)]

pub fn fold_adjacent(
  matrix: Matrix(a),
  coord: Coord,
  init: b,
  with cb: fn(b, a, Coord) -> b,
) -> b {
  list.fold(
    adjacency_dirs,
    init,
    fn(acc, dir) {
      let adj_coord = Coord(x: coord.x + dir.0, y: coord.y + dir.1)
      case get_cell(matrix, adj_coord) {
        Ok(v) -> cb(acc, v, adj_coord)
        Error(Nil) -> acc
      }
    },
  )
}

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

pub fn map(grid: Matrix(a), with mapper: fn(CoordVal(a)) -> b) -> Matrix(b) {
  use y, row <- list.index_map(grid)
  use x, val <- list.index_map(row)
  let coord = Coord(x: x, y: y)
  let cv_in = CoordVal(coord: coord, val: val)
  mapper(cv_in)
}

pub fn fold(grid: Matrix(a), init: b, with folder: fn(b, CoordVal(a)) -> b) -> b {
  use racc, row, y <- list.index_fold(grid, init)
  use acc, val, x <- list.index_fold(row, racc)
  let coord = Coord(x: x, y: y)
  let cv_in = CoordVal(coord: coord, val: val)
  folder(acc, cv_in)
}

pub type Neighbors(a) {
  Neighbors(
    up: Result(CoordVal(a), Nil),
    right: Result(CoordVal(a), Nil),
    down: Result(CoordVal(a), Nil),
    left: Result(CoordVal(a), Nil),
  )
}

pub fn get_neighbors(matrix, coord) {
  let Coord(x: x, y: y) = coord
  let get_neighbor_cv = fn(coord) {
    case get_cell(matrix, coord) {
      Ok(val) -> Ok(CoordVal(coord: coord, val: val))
      _ -> Error(Nil)
    }
  }
  Neighbors(
    up: get_neighbor_cv(Coord(x: x, y: y + 1)),
    right: get_neighbor_cv(Coord(x: x + 1, y: y)),
    down: get_neighbor_cv(Coord(x: x, y: y - 1)),
    left: get_neighbor_cv(Coord(x: x - 1, y: y)),
  )
}

pub fn map_neighbor(
  single_n: Result(CoordVal(a), Nil),
  cb: fn(CoordVal(a)) -> b,
) -> Result(CoordVal(b), Nil) {
  case single_n {
    Ok(cv) -> Ok(map_cv(cv, cb))
    _ -> Error(Nil)
  }
}

pub fn map_neighbors(
  neighbors: Neighbors(a),
  cb: fn(CoordVal(a), Dir) -> b,
) -> Neighbors(b) {
  Neighbors(
    up: result.map(
      neighbors.up,
      fn(v) { CoordVal(coord: v.coord, val: cb(v, Up)) },
    ),
    right: result.map(
      neighbors.right,
      fn(v) { CoordVal(coord: v.coord, val: cb(v, Right)) },
    ),
    down: result.map(
      neighbors.down,
      fn(v) { CoordVal(coord: v.coord, val: cb(v, Down)) },
    ),
    left: result.map(
      neighbors.left,
      fn(v) { CoordVal(coord: v.coord, val: cb(v, Left)) },
    ),
  )
}

pub fn find_exn(
  grid: Matrix(a),
  with predicate: fn(CoordVal(a)) -> Bool,
) -> CoordVal(a) {
  let found = {
    use row, x <- find_map_index(grid)
    use val, y <- find_map_index(row)
    let coord = Coord(x: x, y: y)
    let cv = CoordVal(coord, val)
    case predicate(cv) {
      False -> Error(Nil)
      True -> Ok(cv)
    }
  }
  case found {
    Ok(f) -> f
    Error(_) -> {
      io.debug(#("not found in grid"))
      panic
    }
  }
}

pub fn rotate_neighbors(neighbors: Neighbors(a), cw: Bool) -> Neighbors(a) {
  Neighbors(
    up: case cw {
      True -> neighbors.left
      False -> neighbors.right
    },
    right: case cw {
      True -> neighbors.up
      False -> neighbors.down
    },
    down: case cw {
      True -> neighbors.right
      False -> neighbors.left
    },
    left: case cw {
      True -> neighbors.down
      False -> neighbors.up
    },
  )
}

pub fn merge_neighbors(a: Neighbors(a), b: Neighbors(a), cb) {
  let merge = fn(ra, rb) {
    case ra, rb {
      Ok(cva), Ok(cvb) -> Ok(map_cv(cva, fn(_) { cb(cva, cvb) }))
      Ok(cva), _ -> Ok(cva)
      _, Ok(cvb) -> Ok(cvb)
      _, _ -> Error(Nil)
    }
  }
  Neighbors(
    up: merge(a.up, b.up),
    down: merge(a.down, b.down),
    left: merge(a.left, b.left),
    right: merge(a.right, b.right),
  )
}

pub fn empty_neighbors(
  grid: Matrix(a),
  coord: Coord,
  cb: fn(CoordVal(a), Dir) -> b,
) -> Neighbors(b) {
  grid
  |> get_neighbors(coord)
  |> map_neighbors(cb)
}

pub fn neighbors_to_list(neighbors: Neighbors(a)) {
  [
    #(neighbors.up, Up),
    #(neighbors.down, Down),
    #(neighbors.left, Left),
    #(neighbors.right, Right),
  ]
}

pub fn fold_neighbors(
  neighbors: Neighbors(a),
  init: b,
  with cb: fn(b, CoordVal(a)) -> b,
) -> b {
  neighbors
  |> neighbors_to_list
  |> list.map(fn(x) { x.0 })
  |> list.fold(
    init,
    fn(acc, cv_result) {
      case cv_result {
        Error(_) -> acc
        Ok(cv) -> cb(acc, cv)
      }
    },
  )
}

pub fn neighbor_to_string(neighbors: Neighbors(a), to_string) -> String {
  let to_s = fn(v: Result(CoordVal(a), Nil)) -> String {
    case v {
      Ok(cv) -> to_string(cv.val)
      _ -> " "
    }
  }
  [
    " " <> to_s(neighbors.up) <> " ",
    to_s(neighbors.left) <> " " <> to_s(neighbors.right),
    " " <> to_s(neighbors.down) <> " ",
  ]
  |> string.join("\n")
}
