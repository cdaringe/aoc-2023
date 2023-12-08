import gleam/string
import gleam/list
import gleam/io
import gleam/result

pub fn lines(text: String) {
  string.split(text, on: "\n")
  |> list.filter(fn(x) { x != "" })
}

pub fn expect(r: Result(_, _), msg: String) {
  case r {
    Ok(v) -> v
    Error(_) -> {
      io.println(msg)
      panic
    }
  }
}

pub type AocError {
  ParseError(String)
  BadInput(String)
}

pub fn swap_err(res: Result(a, _), err: AocError) -> Result(a, AocError) {
  result.map_error(res, fn(_) { err })
}

pub fn parse_err(msg: String) {
  ParseError(msg)
}

pub fn input_err(msg: String) {
  BadInput(msg)
}
