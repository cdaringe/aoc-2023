import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/pair as cpair
import gleam/list
import gleam/string
import gleam/bool
import gleam/io
import gleam/set.{Set}

pub fn pt_1(input: String) {
  input
  |> common.lines
  |> list.map(solve_line)
  0
}

pub fn pt_2(_input: String) {
  todo
}

fn solve_line(line: String) -> List(Candidate) {
  let assert [springstr, patternstr] = string.split(line, " ")
  let springs = string.split(springstr, "")
  let candidate =
    list.index_fold(
      springs,
      #([], Error(Nil)),
      fn(acc, c, i) {
        let is_last = { list.length(springs) - 1 } == i
        case acc, c {
          // . broke the group
          #(all, Ok(nonop)), "." -> #([nonop, ..all], Error(Nil))
          // . contiguous or starting edge
          #(_, _), "." -> acc
          // group continuation
          #(all, Ok(nonop)), c if c == "?" || c == "#" -> {
            case is_last {
              True -> #([[c, ..nonop], ..all], Error(Nil))
              False -> #(all, Ok([c, ..nonop]))
            }
          }
          // group starting
          #(all, Error(Nil)), c if c == "?" || c == "#" -> {
            case is_last {
              True -> #([[c], ..all], Error(Nil))
              False -> #(all, Ok([c]))
            }
          }
          _, _ -> panic
        }
      },
    )
    |> cpair.first
    |> list.reverse
  let brokepat =
    string.split(patternstr, ",")
    |> list.map(cint.parse_int_exn)
  find_all_broken_patterns(candidate, brokepat, set.new()).1
}

// [a,b,c,d] -> [ [[a,b,c,d]], [[a], [b,c,d]], [[a,b], [c,d], [[a,b,c], [d]]]
pub fn all_splits(l: List(a)) -> List(List(List(a))) {
  list.index_fold(
    l,
    [],
    fn(acc: List(List(List(a))), _, i: Int) {
      case i == 0 {
        True -> acc
        False -> {
          let #(a, b) = list.split(l, i)
          [[a, b], ..acc]
        }
      }
    },
  )
}

type Candidate =
  List(List(String))

type FoundState =
  #(Set(Candidate), List(Candidate))

fn find_all_broken_patterns(
  candidate: Candidate,
  brokepat: List(Int),
  visited: Set(Candidate),
) -> FoundState {
  use <- bool.guard(set.contains(visited, candidate), #(visited, []))
  let group_len = list.length(candidate)
  let pat_len = list.length(brokepat)
  let visited = set.insert(visited, candidate)
  case group_len == pat_len {
    True -> {
      #(
        visited,
        case is_valid_patterns(candidate, brokepat) {
          True -> [candidate]
          False -> []
        },
      )
    }
    False -> {
      // for every ith group in the candidate...
      let candies: List(Candidate) =
        list.index_map(
          candidate,
          fn(i, g) { generate_next_candidates(i, g, candidate) },
        )
        |> list.flatten

      let state: FoundState =
        candies
        |> list.fold(
          #(visited, []),
          fn(acc: #(Set(Candidate), List(Candidate)), candidate: Candidate) {
            let #(visited, all_candidates) = acc
            let #(next_visited, next_all) =
              find_all_broken_patterns(candidate, brokepat, visited)
            #(next_visited, list.concat([next_all, all_candidates]))
          },
        )
      state
    }
  }
}

pub fn generate_next_candidates(
  i: Int,
  g: List(String),
  candidate: Candidate,
) -> List(Candidate) {
  use <- bool.guard(list.length(g) <= 2, [])
  let #(a, b_inclusive) = list.split(candidate, i)
  let b = list.drop(b_inclusive, 1)
  all_splits(g)
  |> list.map(fn(replacement_gs) { list.concat([a, replacement_gs, b]) })
}

fn is_valid_patterns(candidate, brokepat) {
  case list.length(candidate) == list.length(brokepat) {
    False -> False
    True -> {
      list.zip(candidate, brokepat)
      |> list.all(fn(pair) { list.length(pair.0) == pair.1 })
    }
  }
}
