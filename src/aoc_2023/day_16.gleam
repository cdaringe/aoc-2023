import gleam/list
import aoc_2023/common
import aoc_2023/c/matrix.{Matrix}

pub fn pt_1(input: String) {
  input
  |> parse_matrix
}

pub fn pt_2(input: String) {
  todo
}

pub fn parse_matrix(text) {
  text
  |> common.char_matrix
}

pub fn energize(mat: Matrix(String)) {
  todo
}
