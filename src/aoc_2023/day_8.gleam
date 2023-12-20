import aoc_2023/day_8/network as net
import aoc_2023/day_8/node.{type Node}
import aoc_2023/common
import gleam/list
import gleam/string
import gleam/iterator.{cycle, fold_until, from_list}
import gleam_community/maths/arithmetics

pub type State {
  State(n: Int, node: Node)
}

pub fn pt_1(input: String) {
  let #(dirs, _, network) = parse(input)
  from_list(dirs)
  |> cycle
  |> fold_until(from: State(n: 0, node: net.get_node(network, "AAA")), with: fn(
    state,
    dir,
  ) {
    let next_node = net.get_node(network, net.nav(state.node, dir))
    let next_state = State(n: state.n + 1, node: next_node)
    case next_node.name {
      "ZZZ" -> list.Stop(next_state)
      _ -> list.Continue(next_state)
    }
  })
  |> fn(state: State) { state.n }
}

pub fn pt_2(input: String) {
  let #(dirs, nodes, network) = parse(input)
  let start_nodes = list.filter(nodes, fn(n) { string.ends_with(n.name, "A") })
  let assert [hd, ..tail] =
    start_nodes
    |> list.map(fn(node) {
      from_list(dirs)
      |> cycle
      |> fold_until(from: State(n: 0, node: node), with: fn(state, dir) {
        let next_node = net.get_node(network, net.nav(state.node, dir))
        let next_state = State(n: state.n + 1, node: next_node)
        case string.ends_with(next_node.name, "Z") {
          True -> list.Stop(next_state)
          _ -> list.Continue(next_state)
        }
      })
      |> fn(state: State) { state.n }
    })
  list.fold(tail, hd, fn(lcm, it) { arithmetics.lcm(lcm, it) })
}

fn parse(text: String) {
  let assert [dir_text, ..rest] =
    text
    |> common.lines
  let dirs = net.parse_dirs_line(dir_text)
  let nodes = list.map(rest, node.of_line)
  #(dirs, nodes, net.of_nodes(nodes))
}
