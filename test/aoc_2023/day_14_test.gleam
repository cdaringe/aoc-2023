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

pub fn rotate_cw_test() {
  let i1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  let i2 = day.rotate_cw(i1)
  should.equal(i2, [[7, 4, 1], [8, 5, 2], [9, 6, 3]])

  let i3 = day.rotate_cw(i2)
  should.equal(i3, [[9, 8, 7], [6, 5, 4], [3, 2, 1]])
}

pub fn rotate_cw_input_test() {
  let t0 = input

  let t1 =
    t0
    |> day.parse
    |> day.tilt_cycles
    |> day.pp_platform

  let o1 =
    ".....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#...."
  should.equal(t1, o1)

  let t2 =
    t1
    |> day.parse
    |> day.tilt_cycles
    |> day.pp_platform

  let o2 =
    ".....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#..OO###..
#.OOO#...O"
  should.equal(t2, o2)
  let t3 =
    t2
    |> day.parse
    |> day.tilt_cycles
    |> day.pp_platform

  let o3 =
    ".....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O"
  should.equal(t3, o3)
}

pub fn p2_test() {
  input
  |> day.pt_2
  |> should.equal(64)
}
