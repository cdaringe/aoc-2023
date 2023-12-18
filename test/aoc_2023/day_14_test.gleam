import aoc_2023/day_14 as day
import gleeunit/should

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

pub fn rotate_cw_test() {
  let i1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  let i2 = day.rotate_cw(i1)
  should.equal(i2, [[7, 4, 1], [8, 5, 2], [9, 6, 3]])

  let i3 = day.rotate_cw(i2)
  should.equal(i3, [[9, 8, 7], [6, 5, 4], [3, 2, 1]])
}

pub fn p2_test() {
  input
  |> day.pt_2
  |> should.equal(64)
}
