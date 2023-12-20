import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/result
import gleam/io
import gleam/int
import gleam/set
import gleam/order.{Eq}

pub type Matrix(a) =
  List(List(a))

// A contiguous list of graphemes and their starting index
pub type RowChunk(a) =
  #(List(a), #(Int, Int))

pub fn of_lines(lines: List(String)) -> Matrix(String) {
  list.map(lines, fn(line) { string.split(line, "") })
}

pub fn print(m: Matrix(a), pp) {
  list.each(m, fn(row) {
    list.each(row, fn(c) { io.print(pp(c) <> " ") })
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

type StrTest(a) =
  fn(a) -> Bool

pub fn get_cell(matrix: Matrix(a), yx: #(Int, Int)) -> Option(a) {
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
  matrix: Matrix(a),
  chunk: RowChunk(a),
  test: StrTest(a),
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
  matrix: Matrix(a),
  chunk: RowChunk(a),
  test: StrTest(a),
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
  matrix: Matrix(a),
  chunk: RowChunk(a),
  test: StrTest(a),
) -> List(Coord) {
  let unique = set.new()
  get_neighbor_if_(matrix, chunk, test)
  |> list.filter_map(fn(x) { option.to_result(x, "bummer") })
  |> list.fold(unique, fn(acc, it) { set.insert(acc, it) })
  |> set.to_list
}

type RowChunkBuilder(a) {
  RowChunkBuilder(partial: Option(RowChunk(a)), chunks: List(RowChunk(a)))
}

pub fn find_row_chunks(
  matrix: Matrix(a),
  test_in_chunk: StrTest(a),
) -> List(RowChunk(a)) {
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

pub fn map(mat: Matrix(a), with cb: fn(a, Int, Int) -> b) -> Matrix(b) {
  use y, row <- list.index_map(mat)
  use x, cell <- list.index_map(row)
  cb(cell, y, x)
}

pub fn fold(mat: Matrix(a), init: b, with cb: fn(b, a, Int, Int) -> b) -> b {
  use acc, row, y <- list.index_fold(mat, init)
  use acc, cell, x <- list.index_fold(row, acc)
  cb(acc, cell, y, x)
}

pub fn at(mat: Matrix(a), y: Int, x: Int) {
  let maybe_row = list.at(mat, y)
  let maybe_cell = result.try(maybe_row, fn(row) { list.at(row, x) })
  maybe_cell
}

pub fn at_exn(mat: Matrix(a), y: Int, x: Int) {
  case at(mat, y, x) {
    Ok(v) -> v
    Error(Nil) -> {
      io.debug(#("failed to find cell at y, x", y, x))
      panic
    }
  }
}

pub fn of_list(l: List(a), width: Int) -> Matrix(a) {
  list.fold_right(l, [[]], fn(acc, it) {
    case acc {
      [hd, ..rest] -> {
        case list.length(hd) == width {
          True -> [[it], ..acc]
          False -> [[it, ..hd], ..rest]
        }
      }
      _ -> panic
    }
  })
}

type YX =
  #(Int, Int)

pub fn compare_yx(a: YX, b: YX) -> order.Order {
  let comp = int.compare(a.0, b.0)
  case comp {
    Eq -> int.compare(a.1, b.1)
    _ -> comp
  }
}
