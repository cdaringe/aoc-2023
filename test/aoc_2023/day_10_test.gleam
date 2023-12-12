import aoc_2023/day_10 as day
import aoc_2023/day_10/matrix as dmat
import gleam/set
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

pub fn dmat_coord_eq_test() {
  let c1 = dmat.Coord(x: 1, y: 2)
  let my_set = set.from_list([c1])
  let c2 = dmat.Coord(x: 1, y: 2)
  should.equal(set.contains(my_set, c2), True)
}
// pub fn coord_set_test() {
//   let c1 = dmat.Coord(x: 1, y: 2)
//   let c2 = dmat.Coord(x: 1, y: 2)
//   should.equal(c1, c2)
// }

// const input2 = "..........
// .S------7.
// .|F----7|.
// .||....||.
// .||....||.
// .|L-7F-J|.
// .|..||..|.
// .L--JL--J.
// ........."

// pub fn pt_2_test() {
//   input2
//   |> day.pt_2
//   |> should.equal(8)
// }
