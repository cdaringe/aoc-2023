import aoc_2023/c/graph
import aoc_2023/c/matrix
import aoc_2023/common.{char_matrix}

pub fn pt_1(input: String) {
  todo
}

pub fn pt_2(input: String) {
  todo
}

pub fn parse(text: String) {
  let grid = char_matrix(text)
  grid
  |> matrix.map(fn(cell, y, x) {
    let adjacency_dirs = [#(-1, 0), #(0, -1), #(0, 1), #(1, 0)]
  })
}
