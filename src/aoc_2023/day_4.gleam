import gleam/set.{type Set}
import gleam/list
import gleam/int
import gleam/float
import gleam/string
import gleam/result
import gleam/bool
import aoc_2023/common
import aoc_2023/c/int.{parse_int_exn} as _cint

pub fn pt_1(input: String) {
  input
  |> parse
  |> list.map(score)
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse
  |> score2
}

fn parse(input: String) {
  input
  |> common.lines
  |> list.map(card_of_line)
}

type Card {
  Card(id: Int, winning: Set(Int), has: Set(Int))
}

fn card_of_line(line: String) {
  let assert [p1, p2] =
    string.split(line, ":")
    |> list.map(normalize_line)
  let assert [_, id] = p1
  let assert [winning, has] =
    string.join(p2, " ")
    |> string.split("|")
    |> list.map(fn(s) {
      s
      |> normalize_line
      |> list.map(parse_int_exn)
      |> set.from_list
    })
  Card(id: parse_int_exn(id), winning: winning, has: has)
}

fn score(card: Card) -> Int {
  set.intersection(card.winning, card.has)
  |> set.size
  |> fn(n) {
    case n {
      0 -> 0.0
      n ->
        int.power(2, int.to_float(n - 1))
        |> result.unwrap(0.0)
    }
  }
  |> float.round
}

fn score_ith(ith: Int, cards: List(Card)) {
  1 + case list.at(cards, ith) {
    Ok(card) -> {
      let n = count_matches(card)
      use <- bool.guard(n == 0, 0)
      use total, i <- list.fold(list.range(1, n), 0)
      total + score_ith(ith + i, cards)
    }
    _ -> 0
  }
}

fn count_matches(card: Card) -> Int {
  set.intersection(card.winning, card.has)
  |> set.size
}

fn score2(cards: List(Card)) {
  list.index_fold(cards, 0, fn(total, _, i) { total + score_ith(i, cards) })
}

fn normalize_line(str: String) -> List(String) {
  string.split(str, " ")
  |> list.map(string.trim)
  |> list.filter(fn(x) { x != "" })
}
