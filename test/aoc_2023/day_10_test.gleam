import aoc_2023/day_10 as day
import gleeunit/should

const input = "..F7.
.FJ|.
SJ.L7
|F--J
LJ..."

pub fn pt_1_test() {
  input
  |> day.pt_1
  |> should.equal(8)
}
