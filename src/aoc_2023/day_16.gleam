import gleam/list
import gleam/int
import gleam/bool
import gleam/iterator.{concat, fold, map, range, repeat, zip}
import gleam/map.{type Map}
import gleam/set.{type Set}
import gleam/result
import aoc_2023/common
import aoc_2023/c/matrix
import aoc_2023/c/list as clist

pub fn pt_1(input: String) {
  let #(_mat, unit_map) = parse_matrix(input)
  unit_map
  |> energize(0, 0, R)
  |> map.to_list
  |> list.filter(fn(x) { { x.1 }.energized })
  |> list.length
}

pub fn pt_2(input: String) {
  let #(mat, unit_map) = parse_matrix(input)
  let h = list.length(mat)
  let w = list.length(clist.first_exn(mat))
  concat([
    zip(repeat(0), range(0, w - 1))
    |> map(fn(yx) { #(yx, D) }),
    zip(repeat(h - 1), range(0, w - 1))
    |> map(fn(yx) { #(yx, U) }),
    zip(range(0, h - 1), repeat(0))
    |> map(fn(yx) { #(yx, R) }),
    zip(range(0, h - 1), repeat(w - 1))
    |> map(fn(yx) { #(yx, L) }),
  ])
  |> map(fn(start) {
    let #(#(y, x), dir) = start
    energize(unit_map, y, x, dir)
    |> map.to_list
    |> list.filter(fn(x) { { x.1 }.energized })
    |> list.length
  })
  |> fold(0, fn(max, it) { int.max(max, it) })
}

pub type Unit {
  Unit(char: String, energized: Bool, visited_from: Set(Dir))
}

pub fn uncharged(char: String) {
  Unit(char, False, set.new())
}

pub fn charged(char: String) {
  Unit(char, False, set.new())
}

pub fn charge(unit: Unit, from: Dir) {
  Unit(
    ..unit,
    visited_from: set.insert(unit.visited_from, from),
    energized: True,
  )
}

pub fn parse_matrix(text) -> #(matrix.Matrix(String), UnitMap) {
  let char_matrix = common.char_matrix(text)
  let um =
    char_matrix
    |> matrix.map(fn(v, y, x) { #(#(y, x), uncharged(v)) })
    |> list.flatten
    |> map.from_list
  #(char_matrix, um)
}

pub type Dir {
  U
  R
  D
  L
}

pub type UnitMap =
  Map(#(Int, Int), Unit)

pub fn energize(unit_map: UnitMap, y, x, dir) -> UnitMap {
  let key = #(y, x)
  let cell = map.get(unit_map, key)
  use <- bool.guard(result.is_error(cell), unit_map)
  let unit = common.expect(cell, "!")
  case set.contains(unit.visited_from, dir) {
    True -> unit_map
    False -> {
      let next_dirs = case unit.char, dir {
        // case: continue
        ".", _ -> [dir]
        // case: bar split
        "|", L | "|", R -> [U, D]
        // case: bar deadend
        "|", U | "|", D -> [dir]
        // case: bar split
        "-", L | "-", R -> [dir]
        // case: bar deadend
        "-", U | "-", D -> [L, R]

        "/", R -> [U]
        "/", U -> [R]
        "/", D -> [L]
        "/", L -> [D]

        "\\", R -> [D]
        "\\", U -> [L]
        "\\", D -> [R]
        "\\", L -> [U]

        _, _ -> panic as "unhanded"
      }
      let unit_map = map.insert(unit_map, key, charge(unit, dir))
      use unit_map, dir <- list.fold(next_dirs, unit_map)
      let next_y = case dir {
        U -> y - 1
        D -> y + 1
        _ -> y
      }
      let next_x = case dir {
        L -> x - 1
        R -> x + 1
        _ -> x
      }
      energize(unit_map, next_y, next_x, dir)
    }
  }
}
