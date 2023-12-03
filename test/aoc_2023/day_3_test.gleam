import aoc_2023/day_3
import gleeunit/should

const input = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

pub fn pt_1_test() {
  input
  |> day_3.pt_1
  |> should.equal(4361)
}

pub fn pt_2_test() {
  input
  |> day_3.pt_2
  |> should.equal(467_835)
}
