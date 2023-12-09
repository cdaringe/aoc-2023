import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/list as clist
import gleam/list
import gleam/int
import gleam/string

pub fn pt_1(input: String) {
  input
  |> parse
  |> list.map(cascading_deltas)
  |> list.map(sum_lasts)
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse
  |> list.reverse
  |> list.map(cascading_deltas)
  |> list.map(delta_heads)
  |> list.map(clist.first_exn)
  |> int.sum
}

fn parse(text: String) -> List(List(Int)) {
  text
  |> common.lines
  |> list.map(fn(line) {
    string.split(line, " ")
    |> list.map(cint.parse_int_exn)
  })
}

pub fn cascading_deltas(xs: List(Int)) -> List(List(Int)) {
  let deltas =
    list.window(xs, 2)
    |> list.map(fn(els) {
      case els {
        [a, b] -> b - a
        _ -> panic as "invalid window"
      }
    })
  let is_all_zeros = list.all(deltas, fn(x) { x == 0 })
  case is_all_zeros {
    True -> [xs, deltas]
    False -> [xs, ..cascading_deltas(deltas)]
  }
}

fn sum_lasts(xxs: List(List(Int))) -> Int {
  xxs
  |> list.map(clist.last_exn)
  |> int.sum
}

fn delta_heads(xxs: List(List(Int))) {
  xxs
  |> list.map(clist.first_exn)
  |> list.reverse
  |> list.fold(
    [],
    fn(acc, it) {
      let last = case acc {
        [] -> 0
        [last, ..] -> last
      }
      [it - last, ..acc]
    },
  )
}
