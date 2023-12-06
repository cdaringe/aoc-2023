import aoc_2023/day_6
import gleeunit/should

const input = "Time:      7  15   30
Distance:  9  40  200"

pub fn pt_1_test() {
  input
  |> day_6.pt_1
  |> should.equal(288)
}
