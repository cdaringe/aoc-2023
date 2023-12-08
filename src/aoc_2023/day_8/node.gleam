import gleam/regex.{Match, from_string, scan}
import gleam/option.{Some}

pub type Node {
  Node(name: String, left: String, right: String)
}

pub fn of_line(line: String) {
  let assert Ok(re) = from_string("([A-Z]+) = \\(([A-Z]+), ([A-Z]+)\\)")
  let assert [Match(_, [Some(name), Some(left), Some(right)])] =
    scan(with: re, content: line)
  Node(name, left, right)
}
