import aoc_2023/common
import gleam/list
import gleam/string
import gleam/bool
import gleam/iterator as iter

pub fn pt_1(input: String) {
  input
  |> parse_mirror_maze
  |> list.map(find_reflections)
  |> score_reflections
}

pub fn pt_2(input: String) {
  input
  |> parse_mirror_maze
  |> list.map(find_smudged_reflection)
  |> score_reflections
}

fn score_reflections(reflections) -> Int {
  list.fold(
    reflections,
    #(0, 0),
    fn(acc, reflections) {
      let #(rows, cols) = acc
      case reflections {
        [Col(c)] -> #(rows, cols + c)
        [Row(r)] -> #(rows + r, cols)
        _ -> panic
      }
    },
  )
  |> fn(rc: #(Int, Int)) { rc.1 + { 100 * rc.0 } }
}

pub fn parse_mirror_maze(text) -> List(List(List(String))) {
  text
  |> string.split("\n\n")
  |> list.map(fn(block) {
    block
    |> common.lines
    |> list.map(fn(s) { string.split(s, "") })
  })
}

pub type Reflect {
  Col(Int)
  Row(Int)
}

fn to_col(i: Int) {
  Col(i)
}

fn to_row(i: Int) {
  Row(i)
}

pub fn find_reflections(mirror_maze: List(List(String))) -> List(Reflect) {
  let col_rs =
    find_col_reflections(mirror_maze)
    |> list.map(to_col)
  let row_rs =
    rotate_ccw(mirror_maze)
    |> find_col_reflections
    |> list.map(to_row)
  list.concat([col_rs, row_rs])
}

pub fn find_col_reflections(mirror_maze: List(List(String))) -> List(Int) {
  let assert Ok(r0) = list.at(mirror_maze, 0)
  iter.range(1, { list.length(r0) - 1 })
  |> iter.filter(fn(i) {
    list.all(mirror_maze, fn(row) { has_reflection_string_at(row, i) })
  })
  |> iter.to_list
}

pub fn has_reflection_string_at(chars: List(String), i: Int) -> Bool {
  use <- bool.guard(i == 0, False)
  use <- bool.guard({ list.length(chars) - 1 } == 0, False)
  let #(l, r) = list.split(chars, i)
  let ll = list.reverse(l)
  iter.zip(iter.from_list(ll), iter.from_list(r))
  |> iter.all(fn(pair) { pair.0 == pair.1 })
}

fn col(matrix: List(List(a)), ith: Int) -> List(a) {
  list.map(
    matrix,
    fn(row) {
      let assert Ok(cell) = list.at(row, ith)
      cell
    },
  )
}

pub fn cols(matrix: List(List(a))) -> List(List(a)) {
  let assert Ok(row_0) = list.at(matrix, 0)
  list.range(0, { list.length(row_0) - 1 })
  |> list.map(fn(i) { col(matrix, i) })
}

fn rotate_ccw(matrix: List(List(String))) {
  cols(matrix)
  |> list.reverse
}

type M =
  List(List(String))

type YX =
  #(Int, Int)

fn map_matrix(
  matrix: List(List(String)),
  cb: fn(M, YX) -> a,
) -> iter.Iterator(a) {
  let assert Ok(row_0) = list.at(matrix, 0)
  let r_len = list.length(row_0)
  let col_iter = iter.range(0, { r_len - 1 })
  let row_iter = iter.range(0, list.length(matrix) - 1)
  row_iter
  |> iter.map(fn(y) { iter.map(col_iter, fn(x) { #(y, x) }) })
  |> iter.flatten
  |> iter.map(fn(yx) { cb(matrix, yx) })
}

fn swap_at(over matrix: M, at index: YX, with cb: fn(String) -> String) -> M {
  use y, row <- list.index_map(matrix)
  use x, cell <- list.index_map(row)
  case #(y, x) == index {
    True -> cb(cell)
    _ -> cell
  }
}

fn smudge_char(char) {
  case char {
    "#" -> "."
    "." -> "#"
    _ -> panic as "unexpected char"
  }
}

fn find_smudged_reflection(mirror_maze) {
  let assert [reflection] = find_reflections(mirror_maze)
  map_matrix(
    mirror_maze,
    fn(mat, yx) { swap_at(over: mat, at: yx, with: smudge_char) },
  )
  |> iter.fold_until(
    [],
    fn(_, smudged) {
      case
        find_reflections(smudged)
        |> list.filter(fn(r) { r != reflection })
      {
        [] -> list.Continue([])
        [x] -> list.Stop([x])
        _ -> panic
      }
    },
  )
}
