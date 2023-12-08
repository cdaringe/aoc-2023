import aoc_2023/day_8/node.{type Node}
import gleam/list
import gleam/string
import gleam/map
import gleam/io

pub type Network =
  map.Map(String, Node)

pub type Dir {
  Left
  Right
}

pub fn of_nodes(nodes: List(Node)) {
  nodes
  |> list.map(fn(n) { #(n.name, n) })
  |> map.from_list
}

pub fn nav(node: Node, dir: Dir) {
  case dir {
    Left -> node.left
    Right -> node.right
  }
}

pub fn get_node(n: Network, name: String) {
  // io.debug(#("getting", name))
  // io.debug(n)
  case map.get(n, name) {
    Ok(node) -> node
    _ -> panic as "invalid node"
  }
}

pub fn parse_dirs_line(line: String) {
  line
  |> string.split("")
  |> list.map(fn(c) {
    case c {
      "L" -> Left
      "R" -> Right
      _ -> panic as "bogus char"
    }
  })
}
