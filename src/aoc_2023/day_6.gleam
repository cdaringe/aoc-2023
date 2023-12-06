import gleam/list
import gleam/string
import gleam/iterator as iter
import aoc_2023/c/int as cint

pub fn pt_1(input: String) {
  input
  |> parse_all
  |> list.map(find_winning_races)
  |> list.map(list.length)
  |> list.fold(1, fn(acc, n) { acc * n })
}

pub fn pt_2(input: String) {
  input
  |> parse_as_race
  |> find_winning_races
  |> list.length
}

type Race {
  Race(ms: Int, record: Int)
}

fn find_winning_races(race: Race) -> List(#(Int, Int)) {
  iter.range(0, race.ms)
  |> iter.map(fn(t_charging) {
    let t_racing = race.ms - t_charging
    let d = t_racing * t_charging
    #(d, t_charging)
  })
  |> iter.filter(fn(r) { r.0 > race.record })
  |> iter.to_list
}

fn parse_all(text: String) {
  let assert [times, distances] =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(line) {
      let assert [_label, data_str] =
        string.split(line, ":")
        |> list.map(string.trim)
      data_str
      |> string.split(" ")
      |> list.map(string.trim)
      |> list.filter(fn(x) { x != "" })
      |> list.map(cint.parse_int_exn)
    })
  list.zip(times, distances)
  |> list.map(fn(x) { Race(ms: x.0, record: x.1) })
}

fn parse_as_race(text: String) -> Race {
  let assert [time, distance] =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(line) {
      let assert [_label, data_str] = string.split(line, ":")
      data_str
      |> string.split(" ")
      |> list.map(string.trim)
      |> list.filter(fn(x) { x != "" })
      |> string.join("")
      |> cint.parse_int_exn
    })

  Race(ms: time, record: distance)
}
