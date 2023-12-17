import aoc_2023/day_14 as day
import gleeunit/should
import gleam/string

const input = "O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."

pub fn p1_test() {
  input
  |> day.pt_1
  |> should.equal(136)
}
