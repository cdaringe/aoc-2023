import gleam/regex.{Match, from_string, scan}
import gleam/option.{Some}
import gleam/io

pub type Node {
  Node(name: String, left: String, right: String)
}

pub fn of_line(line: String) {
  let assert Ok(re) =
    from_string("([A-Z0-9]+) = \\(([A-Z0-9]+), ([A-Z0-9]+)\\)")
  case scan(with: re, content: line) {
    [Match(_, [Some(name), Some(left), Some(right)])] -> Node(name, left, right)
    _ -> {
      io.debug(#("bad line", line))
      panic as "bummer"
    }
  }
}
