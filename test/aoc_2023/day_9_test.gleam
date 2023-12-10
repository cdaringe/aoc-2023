import aoc_2023/day_9 as day
import gleeunit/should

const input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"

pub fn pt_1_test() {
  input
  |> day.pt_1
  |> should.equal(114)
}

pub fn pt_2_test() {
  input
  |> day.pt_2
  |> should.equal(2)
}
