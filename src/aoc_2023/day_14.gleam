import aoc_2023/common
import aoc_2023/c/list as clist
import aoc_2023/c/pair as cpair
import gleam/list
import gleam/string
import gleam/bool
import gleam/int
import gleam/order
import gleam/iterator as iter

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
  todo
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
  list.index_fold(
    l,
    0,
    fn(total, spot, i) {
      total + case spot {
        Round -> {
          len - i
        }
        _ -> 0
      }
    },
  )
}
