import aoc_2023/day_16 as day
import gleeunit/should

const input = ".|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|...."

pub fn p1_test() {
  input
  |> day.pt_1
  |> should.equal(46)
}

pub fn p2_test() {
  input
  |> day.pt_2
  |> should.equal(51)
}
