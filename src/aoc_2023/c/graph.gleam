import gleam/map.{type Map}
import gleam/set.{type Set}
import gleam/list
import gleam/bool

// key of dest node, distance from source
pub type OutEdge(key) =
  #(key, Int)

pub fn out_edge(key: key, distance: Int) -> OutEdge(key) {
  #(key, distance)
}

// from node, min_total_distance
pub type DijVisited(from_key) =
  #(from_key, Int)

pub type State(key) =
  Map(key, DijVisited(key))

pub type Node(key) =
  #(key, List(OutEdge(key)))

pub type Graph(key) =
  Map(key, List(OutEdge(key)))

pub fn dijkstra(graph: Graph(key), start: key, big_number: Int) -> State(key) {
  let visited = set.new()
  let state =
    map.fold(
      graph,
      map.new(),
      fn(next, key, _) { map.insert(next, key, #(start, big_number)) },
    )
  let state = map.insert(state, start, #(start, 0))
  let assert Ok(edges) = map.get(graph, start)
  dijkstra_visit(graph, state, visited, #(start, edges), big_number)
}

fn dijkstra_visit(
  graph: Graph(key),
  state: State(key),
  visited: Set(key),
  node: Node(key),
  big_number: Int,
) -> State(key) {
  let #(key, edges) = node
  let assert Ok(#(_, base_distance)) = map.get(state, key)
  let #(state, #(_next_node_distance, next_node_key)) =
    list.filter(edges, fn(e) { !set.contains(visited, e.0) })
    |> list.fold(
      // use big number and current key, even though those will never be traversed to
      #(state, #(big_number, key)),
      // update min distances
      fn(acc, e) {
        let #(state, #(min_unvis_distance, min_unvis_distance_key)) = acc
        let #(to, distance) = e
        let next_distance = distance + base_distance
        let next_min = case next_distance < min_unvis_distance {
          True -> #(next_distance, to)
          False -> #(min_unvis_distance, min_unvis_distance_key)
        }
        let assert Ok(#(_, current_min_distance)) = map.get(state, to)
        use <- bool.guard(
          next_distance > current_min_distance,
          #(state, next_min),
        )
        let next_state = map.insert(state, to, #(key, next_distance))
        #(next_state, next_min)
      },
    )
  let visited = set.insert(visited, key)
  use <- bool.guard(map.size(state) == set.size(visited), state)
  let next_node_key = {
    case next_node_key == key {
      False -> next_node_key
      True ->
        map.fold(
          state,
          #(key, big_number),
          fn(min_unvisted, itk, itv) {
            let #(_, curr_min_dist) = min_unvisted
            use <- bool.guard(set.contains(visited, itk), min_unvisted)
            let #(_, from_dist) = itv
            case from_dist < curr_min_dist {
              True -> itv
              _ -> min_unvisted
            }
          },
        ).0
    }
  }
  let assert Ok(edges) = map.get(graph, next_node_key)
  dijkstra_visit(graph, state, visited, #(next_node_key, edges), big_number)
}
