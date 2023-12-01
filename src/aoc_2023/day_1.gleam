import gleam/result
import gleam/int
import gleam/string
import gleam/list
import gleam/option.{None, Some}

fn is_digit(c: String) {
  case c {
    "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "0" -> True
    _ -> False
  }
}

pub fn extract_code(str: String) {
  str
  |> string.to_graphemes
  |> list.fold(
    #(None, None),
    fn(acc, c) {
      case acc, is_digit(c) {
        _, False -> acc
        #(None, _), _ -> #(Some(c), None)
        #(f, _), _ -> #(f, Some(c))
      }
    },
  )
  |> fn(x) {
    case x {
      #(Some(f), Some(l)) -> int.parse(f <> l)
      #(Some(f), None) -> int.parse(f <> f)
      _ -> Ok(0)
    }
  }
  |> result.unwrap(0)
}

pub fn pt_1(input: String) {
  string.split(input, on: "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.map(extract_code)
  |> list.fold(0, fn(a, b) { a + b })
  |> int.to_string
}

fn swap_text_digit_chars(buf) {
  case buf {
    [] -> []
    ["o", "n", "e", ..rest] -> ["1", "n", "e", ..rest]
    ["t", "w", "o", ..rest] -> ["2", "w", "o", ..rest]
    ["t", "h", "r", "e", "e", ..rest] -> ["3", "h", "r", "e", "e", ..rest]
    ["f", "o", "u", "r", ..rest] -> ["4", "o", "u", "r", ..rest]
    ["f", "i", "v", "e", ..rest] -> ["5", "i", "v", "e", ..rest]
    ["s", "i", "x", ..rest] -> ["6", "i", "x", ..rest]
    ["s", "e", "v", "e", "n", ..rest] -> ["7", "e", "v", "e", "n", ..rest]
    ["e", "i", "g", "h", "t", ..rest] -> ["8", "i", "g", "h", "t", ..rest]
    ["n", "i", "n", "e", ..rest] -> ["9", "i", "n", "e", ..rest]
    _ -> buf
  }
}

fn inline_text_digits(buf) {
  case swap_text_digit_chars(buf) {
    [] -> []
    [x, ..rest] -> [x, ..inline_text_digits(rest)]
  }
}

fn text_to_digits(str: String) -> String {
  str
  |> string.to_graphemes
  |> inline_text_digits
  |> string.join("")
}

pub fn pt_2(input: String) {
  string.split(input, on: "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.map(
    fn(x) {
      x
      |> text_to_digits
      |> extract_code
    },
  )
  |> list.fold(0, fn(a, b) { a + b })
  |> int.to_string
}
