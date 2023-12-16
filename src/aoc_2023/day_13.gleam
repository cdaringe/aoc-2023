import aoc_2023/c/list as clist
import aoc_2023/common
import gleam/list
import gleam/string
import gleam/bool
import gleam/result
import gleam/iterator as iter

pub fn pt_1(input: String) {
  input
  |> parse_blocks
  |> list.map(find_reflection)
  |> list.fold(
    #(0, 0),
    fn(x, it) {
      let #(rows, cols) = x
      case it {
        Col(c) -> #(rows, cols + c)
        Row(r) -> #(rows + r, cols)
      }
    },
  )
  |> fn(rc: #(Int, Int)) { rc.1 + { 100 * rc.0 } }
}

pub fn pt_2(input: String) {
  todo
}

pub fn parse_blocks(text) -> List(List(String)) {
  text
  |> string.split("\n\n")
  |> list.map(fn(block) {
    block
    |> common.lines
  })
}

pub type Reflect {
  Col(Int)
  Row(Int)
}

pub fn find_reflection(block: List(String)) -> Reflect {
  let cr = find_col_reflection(block)
  use <- bool.guard(result.is_ok(cr), Col(result.unwrap(cr, -1000)))
  let rotated_ccw =
    rotate_ccw(
      block
      |> list.map(fn(v) { string.split(v, "") }),
    )
    |> list.map(fn(row) { string.join(row, "") })
  case find_col_reflection(rotated_ccw) {
    Ok(j) -> Row(j)
    _ -> panic as "no reflections"
  }
}

pub fn find_col_reflection(block: List(String)) -> Result(Int, Nil) {
  let assert Ok(r0) = list.at(block, 0)
  iter.range(1, { string.length(r0) - 1 })
  |> iter.find(fn(i) {
    list.all(block, fn(str) { has_reflection_string_at(str, i) })
  })
}

pub fn has_reflection_string_at(str: String, i: Int) -> Bool {
  use <- bool.guard(i == 0, False)
  use <- bool.guard({ string.length(str) - 1 } == 0, False)
  let chars = string.to_graphemes(str)
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
