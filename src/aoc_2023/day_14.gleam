// had it all working except an off by one error. ripped everything apart and
// did a compare with giacomocavalieri's. liked his search better, plucked
// some of it. soln's looked so similar _before_ i even saw his where i wondered
// how he could have seen mine before i submitted it! same modeling and strategy
// precisely--but some tilt and recursive differences. see git history--prior
// iters did the bulk of the same.
import aoc_2023/common
import gleam/list
import gleam/string
import gleam/int
import gleam/map
import gleam/order
import gleam/iterator as iter

const max = 1_000_000_000

pub fn pt_1(input: String) {
  input
  |> parse
  |> fn(spot_matrix) {
    spot_matrix
    |> cols
    |> list.map(fn(column) { tilt(column, True) })
    |> list.map(load_north)
  }
  |> int.sum
}

pub fn pt_2(input: String) {
  let mat =
    input
    |> parse
    |> rotate_ccw
  let cy = find_cycle(mat, 0, map.new())
  iter.range(1, { max - cy.0 } % cy.1)
  |> iter.fold(cy.2, fn(m, _) { tilt_cycles(m) })
  |> list.map(load_north)
  |> int.sum
}

pub fn find_cycle(m, n, cache) {
  let next_m = tilt_cycles(m)
  let next_n = n + 1
  case map.get(cache, next_m) {
    Error(Nil) -> find_cycle(next_m, next_n, map.insert(cache, next_m, next_n))
    Ok(count) -> #(count, next_n - count, next_m)
  }
}

pub fn parse(text: String) -> Platform {
  text
  |> common.lines
  |> list.map(fn(row) {
    string.split(row, "")
    |> list.map(spot_of_char)
  })
}

pub type Platform =
  List(List(Spot))

pub type Spot {
  Empty
  Round
  Cubed
}

fn spot_of_char(char: String) -> Spot {
  case char {
    "." -> Empty
    "O" -> Round
    "#" -> Cubed
    _ -> panic
  }
}

fn char_of_spot(spot: Spot) -> String {
  case spot {
    Empty -> "."
    Round -> "O"
    Cubed -> "#"
    _ -> panic
  }
}

fn is_cubed(x) {
  x == Cubed
}

fn col(matrix: List(List(a)), ith: Int) -> List(a) {
  use row <- list.map(matrix)
  let assert Ok(cell) = list.at(row, ith)
  cell
}

pub fn cols(matrix: List(List(a))) -> List(List(a)) {
  let assert Ok(row_0) = list.at(matrix, 0)
  list.range(0, { list.length(row_0) - 1 })
  |> list.map(fn(i) { col(matrix, i) })
}

fn tilt_matrix(m: Platform) -> Platform {
  list.map(m, fn(r) { tilt_row_left(r, []) })
}

// this is gio's. mine worked fine too.
fn tilt_row_left(row: List(Spot), current_group: List(Spot)) -> List(Spot) {
  case row {
    [] -> current_group
    [Round, ..rest] -> tilt_row_left(rest, [Round, ..current_group])
    [Empty, ..rest] -> tilt_row_left(rest, list.append(current_group, [Empty]))
    [Cubed, ..rest] ->
      list.append(current_group, [Cubed, ..tilt_row_left(rest, [])])
  }
}

pub fn tilt(l: List(Spot), leftwards: Bool) -> List(Spot) {
  let chunks = list.chunk(l, is_cubed)
  {
    use chunk <- list.map(chunks)
    case chunk {
      [] | [Cubed, ..] -> chunk
      non_cubes -> {
        let sorted = {
          use a, b <- list.sort(non_cubes)
          case a, b {
            _, Round -> order.Gt
            Round, _ -> order.Lt
            _, _ -> order.Eq
          }
        }
        case leftwards {
          True -> sorted
          _ -> list.reverse(sorted)
        }
      }
    }
  }
  |> list.flatten
}

fn load_north(l: List(Spot)) {
  let len = list.length(l)
  list.index_fold(l, 0, fn(total, spot, i) {
    total
    + case spot {
      Round -> {
        len - i
      }
      _ -> 0
    }
  })
}

pub fn rotate_cw(matrix: List(List(a))) -> List(List(a)) {
  matrix
  |> list.reverse
  |> list.transpose
}

fn rotate_ccw(matrix: List(List(a))) -> List(List(a)) {
  matrix
  |> rotate_cw
  |> rotate_cw
  |> rotate_cw
}

pub fn tilt_cycles(matrix: Platform) -> Platform {
  matrix
  |> tilt_matrix
  |> rotate_cw
  |> tilt_matrix
  |> rotate_cw
  |> tilt_matrix
  |> rotate_cw
  |> tilt_matrix
  |> rotate_cw
}

pub fn pp_platform(p: Platform) {
  list.map(p, fn(r) {
    list.map(r, char_of_spot)
    |> string.join("")
  })
  |> string.join("\n")
}
