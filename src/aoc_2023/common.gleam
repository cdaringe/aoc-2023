import gleam/string
import gleam/list

pub fn lines(text: String) {
  string.split(text, on: "\n")
  |> list.filter(fn(x) { x != "" })
}
