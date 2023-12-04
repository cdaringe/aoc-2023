import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/result
import gleam/io
import gleam/int
import gleam/set

pub type Matrix =
  List(List(String))

// A contiguous list of graphemes and their starting index
pub type RowChunk =
  #(List(String), #(Int, Int))

pub fn of_lines(lines: List(String)) -> Matrix {
  list.map(lines, fn(line) { string.split(line, "") })
}

pub fn print(m: Matrix) {
  list.each(m, fn(row) {
    list.each(row, fn(c) { io.print(c <> " ") })
    io.println("")
  })
}

type Coord =
  #(Int, Int)

pub fn coord_to_string(c: Coord) {
  "(" <> int.to_string(c.0) <> ", " <> int.to_string(c.1) <> ")"
}

pub fn print_coord(c: Coord) {
  io.println(coord_to_string(c))
}

type StrTest =
  fn(String) -> Bool

pub fn get_cell(matrix: Matrix, yx: #(Int, Int)) -> Option(String) {
  let #(y, x) = yx
  let maybe_row = list.at(matrix, y)
  let maybe_cell = result.try(maybe_row, fn(row) { list.at(row, x) })
  option.from_result(maybe_cell)
}

const adjacency_dirs = [
  #(-1, -1),
  #(-1, 0),
  #(-1, 1),
  #(0, -1),
  #(0, 0),
  #(0, 1),
  #(1, -1),
  #(1, 0),
  #(1, 1),
]

pub fn is_chunk_adjacent_to(
  matrix: Matrix,
  chunk: RowChunk,
  test: StrTest,
) -> Bool {
  let #(y, x) = chunk.1
  use dxx <- list.any(list.index_map(chunk.0, fn(i, _) { i }))
  use dir <- list.any(adjacency_dirs)
  let #(dy, dx) = dir
  case get_cell(matrix, #(y + dy, x + dx + dxx)) {
    Some(neighbor) -> test(neighbor)
    _ -> False
  }
}

pub fn get_neighbor_if_(
  matrix: Matrix,
  chunk: RowChunk,
  test: StrTest,
) -> List(Option(Coord)) {
  let #(y, x) = chunk.1
  let offsets = list.index_map(chunk.0, fn(i, _) { i })
  use dxx <- list.flat_map(offsets)
  use dir <- list.map(adjacency_dirs)
  let #(dy, dx) = dir
  let yx: Coord = #(y + dy, x + dx + dxx)
  case get_cell(matrix, yx) {
    Some(neighbor) -> {
      case test(neighbor) {
        True -> Some(yx)
        _ -> None
      }
    }
    None -> None
  }
}

pub fn get_neighbor_if(
  matrix: Matrix,
  chunk: RowChunk,
  test: StrTest,
) -> List(Coord) {
  let unique = set.new()
  get_neighbor_if_(matrix, chunk, test)
  |> list.filter_map(fn(x) { option.to_result(x, "bummer") })
  |> list.fold(unique, fn(acc, it) { set.insert(acc, it) })
  |> set.to_list
}

type RowChunkBuilder {
  RowChunkBuilder(partial: Option(RowChunk), chunks: List(RowChunk))
}

pub fn find_row_chunks(matrix: Matrix, test_in_chunk: StrTest) -> List(RowChunk) {
  let finalize_partial = fn(partial, chunks) {
    let #(chunk, #(y, x)) = partial
    [#(list.reverse(chunk), #(y, x)), ..chunks]
  }
  list.index_map(matrix, fn(y, row) {
    let state =
      list.index_fold(row, RowChunkBuilder(partial: None, chunks: []), fn(
        builder,
        c,
        x,
      ) {
        case builder.partial, test_in_chunk(c) {
          None, False -> RowChunkBuilder(None, builder.chunks)
          None, True ->
            RowChunkBuilder(
              partial: Some(#([c], #(y, x))),
              chunks: builder.chunks,
            )
          Some(partial), False -> {
            RowChunkBuilder(
              partial: None,
              chunks: finalize_partial(partial, builder.chunks),
            )
          }
          Some(#(rest, #(y, x))), True ->
            RowChunkBuilder(
              partial: Some(#([c, ..rest], #(y, x))),
              chunks: builder.chunks,
            )
        }
      })
    case state.partial {
      Some(partial) -> finalize_partial(partial, state.chunks)
      _ -> state.chunks
    }
    |> list.reverse
  })
  |> list.flatten
}
