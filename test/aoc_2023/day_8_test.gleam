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

const input_2 = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"

pub fn pt_2_test() {
  input_2
  |> day_8.pt_2
  |> should.equal(6)
}
