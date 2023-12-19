import gleam/map
import aoc_2023/c/graph as g
import gleeunit/should

fn make_input() -> g.Graph(String) {
  // input: https://www.youtube.com/watch?v=pVfj6mxhdMw
  map.from_list([
    #("a", [#("b", 6), #("d", 1)]),
    #("b", [#("a", 6), #("c", 5), #("d", 2), #("e", 2)]),
    #("c", [#("b", 5), #("e", 5)]),
    #("d", [#("a", 1), #("b", 2), #("e", 1)]),
    #("e", [#("d", 1), #("b", 2), #("c", 5)]),
  ])
}

pub fn dijkstra_test() {
  let assert Ok(c) =
    make_input()
    |> g.dijkstra("a", 10_000_000)
    |> map.get("c")

  should.equal(c, #("e", 7))
}
