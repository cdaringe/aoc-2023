import aoc_2023/day_5
import gleeunit/should

const input = "seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"

pub fn pt_1_test() {
  input
  |> day_5.pt_1
  |> should.equal(35)
}

pub fn pairs_test() {
  day_5.pairs([1, 2, 7, 6])
  |> should.equal([#(1, 2), #(7, 6)])
}
// pub fn pt_2_test() {
//   input
//   |> day_4.pt_2
//   |> should.equal(30)
// }
