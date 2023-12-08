import aoc_2023/day_8
import gleeunit/should

const input = "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"

pub fn pt_1_test() {
  input
  |> day_8.pt_1
  |> should.equal(6)
}
