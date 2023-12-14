import aoc_2023/day_12 as day
import gleam/set
import gleeunit/should

pub fn all_splits_test() {
  []
  |> day.all_splits(fn(_, _) { True })
  |> should.equal([])
}

pub fn all_splits2_test() {
  [1]
  |> day.all_splits(fn(_, _) { True })
  |> should.equal([])
}

pub fn all_splits3_test() {
  [1, 2]
  |> day.all_splits(fn(_, _) { True })
  |> should.equal([[[1], [2]]])
}

pub fn all_splits4_test() {
  [1, 2, 3]
  |> day.all_splits(fn(_, _) { True })
  |> should.equal([[[1, 2], [3]], [[1], [2, 3]]])
}

pub fn all_splits5_test() {
  [1, 2, 3, 4]
  |> day.all_splits(fn(_, _) { True })
  |> should.equal([[[1, 2, 3], [4]], [[1, 2], [3, 4]], [[1], [2, 3, 4]]])
}
