import aoc_2023/day_12 as day
import gleam/set
import gleeunit/should

pub fn all_splits_test() {
  []
  |> day.all_splits
  |> should.equal([])
}
