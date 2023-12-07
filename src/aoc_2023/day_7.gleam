import gleam/list
import gleam/string
import gleam/map
import gleam/order
import gleam/int
import aoc_2023/common
import aoc_2023/c/int as cint
import aoc_2023/c/map as cmap

pub fn pt_1(input: String) {
  parse_hands(input, Jack)
  |> to_points
}

pub fn pt_2(input: String) {
  parse_hands(input, Joker)
  |> to_points
}

fn to_points(hands) {
  hands
  |> list.sort(compare_hand)
  |> list.index_map(fn(i, hand: Hand) { hand.bid * { i + 1 } })
  |> list.fold(0, int.add)
}

type JMode {
  Jack
  Joker
}

type Card {
  Card(value: Int, sym: String)
}

fn card_of_char(char: String, jmode: JMode) -> Card {
  case char {
    "A" -> Card(value: 14, sym: char)
    "K" -> Card(value: 13, sym: char)
    "Q" -> Card(value: 12, sym: char)
    "J" ->
      Card(
        value: case jmode {
          Jack -> 11
          Joker -> 0
        },
        sym: char,
      )
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
  FiveOfKind
  FourOfKind
  FullHouse
  ThreeOfKind
  TwoPair
  OnePair
  HighCard
}

fn strength_of_hand_type(ht: HandType) {
  case ht {
    FiveOfKind(..) -> 7
    FourOfKind(..) -> 6
    FullHouse(..) -> 5
    ThreeOfKind(..) -> 4
    TwoPair(..) -> 3
    OnePair(..) -> 2
    HighCard(..) -> 1
  }
}

type Hand {
  Hand(typ: HandType, cards: List(Card), bid: Int)
}

fn compare_hand(a: Hand, b: Hand) {
  let a_strength = strength_of_hand_type(a.typ)
  let b_strength = strength_of_hand_type(b.typ)
  let typ_order = int.compare(a_strength, b_strength)
  case typ_order {
    // case: hand types don't settle, drop to card strength
    order.Eq -> {
      list.zip(a.cards, b.cards)
      |> list.find_map(fn(pair: #(Card, Card)) {
        case int.compare({ pair.0 }.value, { pair.1 }.value) {
          order.Eq -> Error(Nil)
          ord -> Ok(ord)
        }
      })
      |> common.expect("unbreakable tie")
    }
    _ -> typ_order
  }
}

type CardCount {
  CC(card: Card, count: Int)
}

fn parse_hands(text: String, jmode: JMode) {
  text
  |> common.lines
  |> list.map(fn(line) {
    let assert [chars_str, bid_str] = string.split(line, " ")
    let bid = cint.parse_int_exn(bid_str)
    let cards =
      string.split(chars_str, "")
      |> list.map(fn(c) { card_of_char(c, jmode) })

    let desc_counts =
      list.fold(
        cards,
        map.new(),
        fn(n_by_card, card) { cmap.upsert(n_by_card, card, 1, fn(n) { n + 1 }) },
      )
      |> map.to_list
      |> list.map(fn(kv) { CC(card: kv.0, count: kv.1) })
      |> list.sort(fn(a, b) { int.compare(b.count, a.count) })
      |> fn(l) {
        case jmode {
          Joker -> jokerify(l)
          _ -> l
        }
      }
      |> list.map(fn(cc) { cc.count })

    let typ = case desc_counts {
      [5] -> FiveOfKind
      [4, 1] -> FourOfKind
      [3, 2] -> FullHouse
      [3, 1, 1] -> ThreeOfKind
      [2, 2, 1] -> TwoPair
      [2, 1, 1, 1] -> OnePair
      [1, 1, 1, 1, 1] -> HighCard
      _ -> panic as "invalid layout"
    }
    Hand(typ: typ, cards: cards, bid: bid)
  })
}

fn jokerify(sorted: List(CardCount)) {
  case list.pop(sorted, fn(cc) { cc.card.sym == "J" }) {
    Ok(#(jcc, [a, ..rest])) -> {
      [CC(a.card, a.count + jcc.count), ..rest]
    }
    _ -> sorted
  }
}
