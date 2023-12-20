import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/list.{with_window_2} as clist
import gleam/list.{fold_right, window}
import gleam/int
import gleam/bool
import gleam/string

pub fn pt_1(input: String) {
  input
  |> parse
  |> list.map(cascade_deltas)
  |> list.map(sum_lasts)
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse
  |> list.reverse
  |> list.map(cascade_deltas)
  |> list.map(delta_heads)
  |> list.map(clist.first_exn)
  |> int.sum
}

fn parse(text: String) -> List(List(Int)) {
  let lines =
    text
    |> common.lines
  use line <- list.map(lines)
  line
  |> string.split(" ")
  |> list.map(cint.parse_int_exn)
}

pub fn cascade_deltas(xs) {
  let #(deltas, is_all_zeros) = {
    use #(all, is_all_zeros), pair <- fold_right(window(xs, 2), #([], True))
    use a, b <- with_window_2(pair)
    let diff = b - a
    #([diff, ..all], is_all_zeros && diff == 0)
  }
  use <- bool.guard(is_all_zeros, [xs, deltas])
  [xs, ..cascade_deltas(deltas)]
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
  |> list.fold([], fn(acc, it) {
    let last = case acc {
      [] -> 0
      [last, ..] -> last
    }
    [it - last, ..acc]
  })
}
