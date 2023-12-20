// A mediocre impl was here (see history), but not correct.
// This impl is a re-impl inspired by https://github.com/giacomocavalieri/aoc_gleam/blob/main/src/aoc_2023/day_12.gleam
import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/pair as cpair
import gleam/list
import gleam/string
import gleam/bool
import gleam/int
import gleam/map
import gleam/result

pub type SpringRow {
  SpringRow(springs: String, pattern: List(Int))
}

pub fn pt_1(input: String) {
  input
  |> common.lines
  |> list.map(parse_line)
  |> solve
}

pub fn pt_2(input: String) {
  input
  |> common.lines
  |> list.map(parse_line)
  |> list.map(quintuplify)
  |> solve
}

fn parse_line(line: String) -> SpringRow {
  let assert [springs, patternstr] = string.split(line, " ")
  let pattern =
    string.split(patternstr, ",")
    |> list.map(cint.parse_int_exn)
  SpringRow(springs: springs, pattern: pattern)
}

pub fn solve(rows: List(SpringRow)) -> Int {
  {
    use visited, row <- list.map_fold(over: rows, from: map.new())
    let #(count, visited) = sum_visit_all_rows(row, visited)
    #(visited, count)
  }
  |> cpair.second
  |> int.sum
}

type VisitState =
  #(Int, map.Map(SpringRow, Int))

pub fn sum_visit_all_rows(
  row: SpringRow,
  visited: map.Map(SpringRow, Int),
) -> VisitState {
  let previous = map.get(visited, row)
  use <- bool.guard(result.is_ok(previous), #(
    result.unwrap(previous, 0),
    visited,
  ))
  case row.springs, row.pattern {
    // case: springs consumed, perfect match
    "", [] -> #(1, visited)

    // case: springs consumed, pattern not consumed
    "", _ -> #(0, visited)

    // case: springs unconsumed, pattern consumed
    "#" <> _, [] -> #(0, visited)

    // case: springs unconsumed, pattern unconsumed. traverse!
    "#" <> _, [n, ..pattern] ->
      case try_chomp_down_springs(row.springs, n) {
        Ok(springs) ->
          sum_visit_all_rows(
            SpringRow(springs: springs, pattern: pattern),
            visited,
          )
        Error(_) -> #(0, visited)
      }

    // case: non-pattern consuming char--skip!
    "." <> springs, patterns ->
      sum_visit_all_rows(SpringRow(springs, patterns), visited)
    "?" <> springs, patterns -> {
      let #(one, visited) =
        sum_visit_all_rows(SpringRow("." <> springs, patterns), visited)
      let visited =
        map.insert(visited, SpringRow("." <> springs, patterns), one)
      let #(other, visited) =
        sum_visit_all_rows(SpringRow("#" <> springs, patterns), visited)
      let visited =
        map.insert(visited, SpringRow("#" <> springs, patterns), other)
      #(one + other, visited)
    }
  }
}

// Given a spring and how many springs must be present in the next group,
// n, chomp down that group to it's minimally valid state.
fn try_chomp_down_springs(springs: String, n: Int) -> Result(String, Nil) {
  case n, springs {
    // case: contiguous group too big for n
    0, "#" <> _ -> Error(Nil)
    // case: n big enough
    0, springs -> Ok(string.drop_left(springs, 1))
    // case: not enough springs to fit inside n
    _, "" | _, "." <> _ -> Error(Nil)
    // case: chomp down n with a spring or maybe-spring, try next
    _, "#" <> springs | _, "?" <> springs ->
      try_chomp_down_springs(springs, n - 1)
  }
}

fn quintuplify(row: SpringRow) {
  SpringRow(
    springs: list.repeat(row.springs, 5)
    |> string.join("?"),
    pattern: list.concat(list.repeat(row.pattern, 5)),
  )
}
