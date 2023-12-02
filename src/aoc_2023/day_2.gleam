import aoc_2023/common.{lines}
import aoc_2023/c/list.{first_exn} as _
import aoc_2023/c/int.{parse_int_exn} as _
import gleam/list
import gleam/option
import gleam/regex
import gleam/result
import gleam/string
import gleam/int.{max, sum}

pub type Game {
  Game(id: Int, draws: List(Draw))
}

type Draw =
  #(Int, Int, Int)

pub fn pt_1(input: String) {
  input
  |> lines
  |> list.map(game_of_line)
  |> list.filter_map(fn(game) {
    case list.all(game.draws, check_valid_draw) {
      True -> Ok(game.id)
      _ -> Error("invalid draws")
    }
  })
  |> sum
}

pub fn pt_2(input: String) {
  input
  |> lines
  |> list.map(game_of_line)
  |> list.map(power)
  |> sum
}

fn get_submatches(match: regex.Match) {
  option.values(match.submatches)
}

type Color {
  R
  G
  B
}

fn parse_color_count_text(text: String) -> #(Int, Color) {
  let assert Ok(re) = regex.from_string("\\s*(\\d+)\\s+([a-z]+)")
  regex.scan(re, text)
  |> list.map(fn(match: regex.Match) {
    case option.values(match.submatches) {
      [id, "red"] -> Ok(#(parse_int_exn(id), R))
      [id, "green"] -> Ok(#(parse_int_exn(id), G))
      [id, "blue"] -> Ok(#(parse_int_exn(id), B))
      _ -> Error("bad color: " <> match.content)
    }
  })
  |> result.values
  |> first_exn
}

fn draw_of_string(draw_text) -> Draw {
  draw_text
  |> string.split(",")
  |> list.map(parse_color_count_text)
  |> list.fold(
    #(0, 0, 0),
    fn(acc, it) {
      let #(r, g, b) = acc
      case it.1 {
        R -> #(r + it.0, g, b)
        G -> #(r, g + it.0, b)
        B -> #(r, g, b + it.0)
      }
    },
  )
}

fn game_of_line(line: String) -> Game {
  let assert Ok(#(p1, p2)) = string.split_once(line, on: ":")
  let assert Ok(re_id) = regex.from_string("Game (\\d+)")
  let assert Ok(id_str) =
    regex.scan(re_id, p1)
    |> list.map(get_submatches)
    |> list.flatten
    |> list.first
  let id = parse_int_exn(id_str)
  let assert Ok(re_bag_draws) = regex.from_string("(\\s\\d+\\s[a-z]+[^;])+")
  let draws =
    regex.scan(re_bag_draws, p2)
    |> list.map(fn(m) { m.content })
    |> list.map(draw_of_string)
  Game(id, draws)
}

fn check_valid_draw(draw: Draw) {
  draw.0 <= 12 && draw.1 <= 13 && draw.2 <= 14
}

fn power(game: Game) -> Int {
  let #(r, g, b) =
    list.fold(
      game.draws,
      #(0, 0, 0),
      fn(min, draw) {
        #(max(min.0, draw.0), max(min.1, draw.1), max(min.2, draw.2))
      },
    )
  r * g * b
}


