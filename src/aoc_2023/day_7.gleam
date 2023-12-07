import gleam/list
import gleam/bool
import gleam/string
import gleam/map
import gleam/set
import gleam/int
import gleam/io
import gleam/iterator as iter
import gleam/option.{type Option, None, Some}
import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/map as cmap

pub fn pt_1(input: String) {
  parse_hands(input)
  |> list.length
}

pub fn pt_2(input: String) {
  todo
}

type Card {
  Card(value: Int, sym: String)
}

fn card_of_char(char: String) -> Card {
  case char {
    "A" -> Card(value: 14, sym: char)
    "K" -> Card(value: 13, sym: char)
    "Q" -> Card(value: 12, sym: char)
    "J" -> Card(value: 11, sym: char)
    "T" -> Card(value: 10, sym: char)
    "9" -> Card(value: 9, sym: char)
    "8" -> Card(value: 8, sym: char)
    "7" -> Card(value: 7, sym: char)
    "6" -> Card(value: 6, sym: char)
    "5" -> Card(value: 5, sym: char)
    "4" -> Card(value: 4, sym: char)
    "3" -> Card(value: 3, sym: char)
    "2" -> Card(value: 2, sym: char)
    _ -> panic as "bad_char"
  }
}

type HandType {
  // Five of a kind, where all five cards have the same label: AAAAA
  FiveOfKind(char: String)
  // Four of a kind, where four cards have the same label and one card has a different label: AA8AA
  FourOfKind(cards_4: String, cards_1: String)

  // Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
  FullHouse(char_3: String, char_2: String)

  // Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
  ThreeOfKind(char_3: String, x: String, y: String)

  // Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
  TwoPair(p1: String, p2: String, x: String)

  // One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
  OnePair(p1: String, x: String, y: String, z: String)

  // High card, where all cards' labels are distinct: 23456
  HighCard(desc: #(String, String, String, String, String))
}

type Hand {
  Hand(typ: HandType, cards: List(Card), bid: Int)
}

type OrderedCard {
  OrderedCard(card: Card, pos: Int)
}

fn parse_hands(text: String) {
  text
  |> common.lines
  |> list.map(fn(line) {
    let assert [chars_str, bid_str] = string.split(line, " ")
    let bid = cint.parse_int_exn(bid_str)
    let cards =
      string.split(chars_str, "")
      |> list.map(card_of_char)
    let ordered_cards =
      cards
      |> list.index_map(fn(pos, card) { OrderedCard(card: card, pos: pos) })
      |> list.sort(fn(a, b) { int.compare(a.pos, b.pos) })
    let card_values_set =
      ordered_cards
      |> list.map(fn(oc) { oc.card.value })
      |> set.from_list
    let set_len = set.size(card_values_set)
    let assert Ok(card_0) = list.at(cards, 0)
    use <- bool.guard(
      set_len == 1,
      Hand(typ: FiveOfKind(char: card_0.sym), cards: cards, bid: bid),
    )
    let cards_by_desc_occurence =
      list.fold(
        cards,
        map.new(),
        fn(n_by_card, card) { cmap.upsert(n_by_card, card, 1, fn(n) { n + 1 }) },
      )
      |> map.to_list
      |> list.sort(fn(a, b) { int.compare(b.1, a.1) })
    case cards_by_desc_occurence {
      [#(a, 4), #(b, 1)] ->
        Hand(
          typ: FourOfKind(cards_4: a.sym, cards_1: b.sym),
          cards: cards,
          bid: bid,
        )
      [#(a, 3), #(b, 2)] ->
        Hand(
          typ: FullHouse(char_3: a.sym, char_2: b.sym),
          cards: cards,
          bid: bid,
        )
      [#(a, 3), #(b, 1), #(c, 1)] ->
        Hand(
          typ: ThreeOfKind(char_3: a.sym, x: b.sym, y: c.sym),
          cards: cards,
          bid: bid,
        )
      [#(a, 2), #(b, 2), #(c, 1)] ->
        Hand(
          typ: TwoPair(p1: a.sym, p2: b.sym, x: c.sym),
          cards: cards,
          bid: bid,
        )
      [#(a, 2), #(b, 1), #(c, 1), #(d, 1)] ->
        Hand(
          typ: OnePair(p1: a.sym, x: b.sym, y: c.sym, z: d.sym),
          cards: cards,
          bid: bid,
        )
      [#(a, 1), #(b, 1), #(c, 1), #(d, 1), #(e, 1)] ->
        Hand(
          typ: HighCard(desc: #(a.sym, b.sym, c.sym, d.sym, e.sym)),
          cards: cards,
          bid: bid,
        )
    }
  })
}
