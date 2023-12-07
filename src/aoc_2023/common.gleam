import gleam/string
import gleam/list
import gleam/io

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
