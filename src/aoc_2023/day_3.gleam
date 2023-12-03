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

  matrix.find_row_chunks(grid, cchar.is_digit)
  |> list.filter(fn(chunk) { matrix.is_chunk_adjacent_to(grid, chunk, is_sym) })
  |> list.map(chunk_to_int)
  |> int.sum
}

pub fn pt_2(input: String) -> Int {
  let grid =
    input
    |> lines
    |> matrix.of_lines

  let chunks_by_star_coord = {
    let all_chunks = matrix.find_row_chunks(grid, cchar.is_digit)
    use chunks_by_star_coord, chunk <- list.fold(all_chunks, map.new())
    case matrix.get_neighbor_if(grid, chunk, is_star) {
      [] -> chunks_by_star_coord
      star_coords -> {
        use acc, coord <- list.fold(star_coords, chunks_by_star_coord)
        use maybe_chunks <- map.update(acc, coord)
        case maybe_chunks {
          Some(chunks) -> [chunk, ..chunks]
          None -> [chunk]
        }
      }
    }
  }

  chunks_by_star_coord
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

fn chunk_to_int(chunk: matrix.RowChunk) {
  list.map(chunk.0, cint.parse_int_exn)
  |> int.undigits(10)
  |> result.unwrap(0)
}

fn is_star(c: String) {
  c == "*"
}
