import aoc_2023/day_15 as day
import gleeunit/should

const input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

pub fn p1_test() {
  "HASH"
  |> day.hash
  |> should.equal(52)
}

pub fn p1_a_test() {
  "rn"
  |> day.hash
  |> should.equal(0)

  "qp"
  |> day.hash
  |> should.equal(1)
}

pub fn p2_test() {
  input
  |> day.pt_2
  |> should.equal(145)
}
