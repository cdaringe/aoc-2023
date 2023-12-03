import gleam/result
import gleam/list
import gleam/int
import gleam/map
import gleam/option.{None, Some}
import aoc_2023/common.{lines}
import aoc_2023/c/matrix
import aoc_2023/c/int as cint
import aoc_2023/c/char as cchar

pub fn pt_1(input: String) {
  let grid =
    input
    |> lines
    |> matrix.of_lines

  matrix.find_chunks(grid, cchar.is_digit)
  |> list.filter(fn(chunk) { matrix.is_chunk_adjacent_to(grid, chunk, is_sym) })
  |> list.map(chunk_to_int)
  |> int.sum
}

type ChunksByStarCoords =
  map.Map(matrix.Coord, List(matrix.Chunk))

pub fn pt_2(input: String) -> Int {
  let grid =
    input
    |> lines
    |> matrix.of_lines

  let chunks_by_star =
    list.fold(
      matrix.find_chunks(grid, cchar.is_digit),
      map.new(),
      fn(chunks_by_star, chunk) {
        case matrix.get_neighbor_if(grid, chunk, fn(it) { it == "*" }) {
          [] -> chunks_by_star
          star_coords ->
            list.fold(
              star_coords,
              chunks_by_star,
              fn(acc: ChunksByStarCoords, coord: matrix.Coord) {
                map.update(
                  in: acc,
                  update: coord,
                  with: fn(o) {
                    case o {
                      Some(chunks) -> [chunk, ..chunks]
                      None -> [chunk]
                    }
                  },
                )
              },
            )
        }
      },
    )

  chunks_by_star
  |> map.filter(fn(_, chunks) { list.length(chunks) == 2 })
  |> map.values
  |> list.map(fn(chunks) {
    chunks
    |> list.map(chunk_to_int)
    |> list.fold(1, int.multiply)
  })
  |> int.sum
}

fn is_sym(c) {
  case c, cchar.is_digit(c) {
    _, True -> False
    ".", False -> False
    _, False -> True
  }
}

fn chunk_to_int(chunk: matrix.Chunk) {
  list.map(chunk.0, cint.parse_int_exn)
  |> int.undigits(10)
  |> result.unwrap(0)
}
