import gleam/string
import gleam/list
import gleam/int
import gleam/map
import aoc_2023/c/int as cint
import aoc_2023/common

pub fn pt_1(input: String) {
  input
  |> parse
  |> list.map(hash)
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse
  |> list.map(parse_step)
  |> apply_steps
  |> map.to_list
  |> list.map(focus_power)
  |> int.sum
}

pub type Lens {
  Lens(label: String, len: Int)
}

pub type Op {
  Rm
  Insert(Lens)
}

pub type Step {
  Step(hash: Int, label: String, op: Op)
}

pub fn focus_power(box_lenses: #(Int, List(Lens))) {
  let #(box_id, lenses) = box_lenses
  use total, lens, i <- list.index_fold(lenses, 0)
  total + { { 1 + box_id } * { i + 1 } * lens.len }
}

pub fn apply_steps(steps: List(Step)) {
  let by_id: map.Map(Int, List(Lens)) =
    list.range(0, 255)
    |> list.map(fn(i) { #(i, []) })
    |> map.from_list
  use by_id, step <- list.fold(steps, by_id)
  let lenses =
    map.get(by_id, step.hash)
    |> common.expect("!")
  let next_lenses = case step.op {
    Rm -> lenses_without_label(lenses, step.label)
    Insert(lens) -> lenses_insert(lenses, lens)
  }
  map.insert(by_id, step.hash, next_lenses)
}

pub fn lenses_without_label(lenses: List(Lens), label) {
  list.filter(lenses, fn(lens) { lens.label != label })
}

pub fn lenses_insert(lenses: List(Lens), lens: Lens) {
  let #(next, did_replace) =
    list.fold_right(lenses, #([], False), fn(acc, it) {
      let #(acc, did_replace) = acc
      case it.label == lens.label, did_replace {
        // case: swap!
        True, False -> #([lens, ..acc], True)
        _, _ -> #([it, ..acc], did_replace)
      }
    })
  case did_replace {
    True -> next
    False -> list.concat([next, [lens]])
  }
}

pub fn parse_step(text: String) {
  case string.ends_with(text, "-") {
    True -> {
      let assert [label, ..] = string.split(text, "-")
      Step(hash: hash(label), label: label, op: Rm)
    }
    False -> {
      let assert [label, lenstr] = string.split(text, "=")
      Step(
        hash: hash(label),
        label: label,
        op: Insert(Lens(label: label, len: cint.parse_int_exn(lenstr))),
      )
    }
  }
}

pub fn parse(text) {
  string.split(text, ",")
  |> list.map(string.trim)
  |> list.filter(fn(s) { s != "" })
}

pub fn hash(parts: String) -> Int {
  let asciis =
    parts
    |> string.to_utf_codepoints
    |> list.map(string.utf_codepoint_to_int)
  use acc, it <- list.fold(asciis, 0)
  { { acc + it } * 17 } % 256
}
