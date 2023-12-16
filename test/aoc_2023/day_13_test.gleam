import aoc_2023/day_13 as day
import gleeunit/should
import gleam/string

const input = "#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"

pub fn p1_test() {
  input
  |> day.pt_1
  |> should.equal(405)
}

pub fn reflection_string_test() {
  ""
  |> string.split("")
  |> day.has_reflection_string_at(0)
  |> should.equal(False)

  " "
  |> string.split("")
  |> day.has_reflection_string_at(1)
  |> should.equal(False)

  " xx "
  |> string.split("")
  |> day.has_reflection_string_at(1)
  |> should.equal(False)

  " xx "
  |> string.split("")
  |> day.has_reflection_string_at(2)
  |> should.equal(True)

  " xy "
  |> string.split("")
  |> day.has_reflection_string_at(2)
  |> should.equal(False)

  "!  xy  !"
  |> string.split("")
  |> day.has_reflection_string_at(2)
  |> should.equal(False)

  "!  xx  !"
  |> string.split("")
  |> day.has_reflection_string_at(4)
  |> should.equal(True)

  "  !!"
  |> string.split("")
  |> day.has_reflection_string_at(3)
  |> should.equal(True)
}
