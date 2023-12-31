import aoc_2023/day_7
import gleeunit/should
import gleam/result
import aoc_2023/common

const input = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"

pub fn pt_1_test() {
  input
  |> day_7.pt_1
  |> common.expect("no error")
  |> should.equal(6440)
}

pub fn pt_2_test() {
  input
  |> day_7.pt_2
  |> common.expect("no error")
  |> should.equal(5905)
}
