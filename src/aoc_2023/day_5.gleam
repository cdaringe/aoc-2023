import gleam/list
import gleam/string
import gleam/map
import gleam/int
import gleam/io
import gleam/iterator as iter
import gleam/option.{type Option, None, Some}
import aoc_2023/common
import aoc_2023/c/int as cint

pub fn pt_1(input: String) {
  let lines = common.lines(input)
  let assert Ok(#(l1, rest)) = list.pop(lines, fn(x) { True })
  let seeds = parse_seed_line(l1)
  let maps_by_name: ResourceMapByFT =
    parse_map_lines(rest)
    |> list.fold(
      map.new(),
      fn(acc, rm) { map.insert(acc, #(rm.from, rm.to), rm) },
    )

  seeds
  |> list.map(fn(s) { loc_of_seed(s, maps_by_name) })
  |> list.fold(999_999_999, fn(acc, it) { int.min(acc, it) })
}

pub fn pt_2(input: String) {
  let lines = common.lines(input)
  let assert Ok(#(l1, rest)) = list.pop(lines, fn(_) { True })
  let maps_by_name: ResourceMapByFT =
    parse_map_lines(rest)
    |> list.fold(
      map.new(),
      fn(acc, rm) { map.insert(acc, #(rm.from, rm.to), rm) },
    )

  let max =
    map.values(maps_by_name)
    |> list.map(max_of_ranges)
    |> list.fold(0, fn(max, it) { int.max(max, it) })

  io.debug(#("max", max))
  io.debug("preparse")
  let seq =
    parse_seed_line(l1)
    |> pairs
    |> list.map(fn(pair) {
      let #(start, len) = pair
      let upper = start + len - 1
      let exceeds_max = upper > max
      let len_to_max = max - start
      #(
        start,
        case exceeds_max {
          True -> {
            io.debug(#("truncated", upper - max))
            len_to_max
          }
          _ -> {
            io.debug(#("upper", upper, "is less than", max, "skipping"))
            len
          }
        },
      )
    })
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.map(fn(x) {
      io.debug(#("start", x.0, "len", x.1, "upper", x.0 + x.1))
      iter.range(x.0, x.0 + x.1)
    })
    |> iter.from_list
    |> iter.flatten
  io.debug("postseq")
  seq
  |> iter.fold(
    #(0, 999_999_999_999),
    fn(acc, seed) {
      let #(count, min) = acc
      case int.modulo(count, 1_000_000) {
        Ok(0) -> {
          io.debug(#("@count", count))
          Nil
        }
        _ -> Nil
      }
      #(count + 1, int.min(min, loc_of_seed(seed, maps_by_name)))
    },
  )
  |> fn(x: #(Int, Int)) { x.1 }
}

fn loc_of_seed(seed: Int, maps_by_name) {
  collect_resources(maps_by_name, #("seed", "soil"), seed)
}

fn parse_seed_line(line: String) -> List(Int) {
  string.replace(line, "seeds: ", "")
  |> string.split(" ")
  |> list.map(cint.parse_int_exn)
}

fn collect_resources(
  maps_by_name: ResourceMapByFT,
  from_to: FromTo,
  value: Int,
) -> Int {
  let assert Ok(rm) = map.get(maps_by_name, from_to)
  let value = case
    list.find_map(
      rm.ranges,
      fn(r) {
        let Range(src, dest, len) = r
        // io.debug(value)
        // io.debug(#(src, dest, len, from_to.1))
        case value >= src && value < { src + len } {
          True -> Ok(dest + { value - src })
          False -> Error(Nil)
        }
      },
    )
  {
    Ok(v) -> v
    _ -> value
  }
  case from_to.1 {
    "location" -> value
    _ -> {
      let assert Ok(next_from_to) =
        map.keys(maps_by_name)
        |> list.find(fn(it) { from_to.1 == it.0 })
      collect_resources(maps_by_name, next_from_to, value)
    }
  }
}

type Range {
  Range(src: Int, dest: Int, len: Int)
}

fn format_range(r: Range) {
  [
    "src: " <> int.to_string(r.src),
    "dest: " <> int.to_string(r.dest),
    "len: " <> int.to_string(r.len),
  ]
  |> string.join(", ")
}

type FromTo =
  #(String, String)

type ResourceMap {
  ResourceMap(from: String, to: String, ranges: List(Range))
}

fn max_of_ranges(rm: ResourceMap) -> Int {
  rm.ranges
  |> list.map(fn(rng) { rng.src + rng.len - 1 })
  |> list.fold(-1, fn(max, it) { int.max(max, it) })
}

type ResourceMapByFT =
  map.Map(FromTo, ResourceMap)

type Builder {
  Builder(all: List(ResourceMap), partial: Option(ResourceMap))
}

fn parse_from_to(s: String) {
  let assert [from, to] =
    s
    |> string.replace(" map:", "")
    |> string.split("-to-")
  #(from, to)
}

fn parse_map_lines(lines: List(String)) -> List(ResourceMap) {
  let parsed =
    list.fold(
      lines,
      Builder([], None),
      fn(b: Builder, line) {
        case b.partial, string.ends_with(line, ":") {
          None, False -> panic as "bummer"
          None, True -> {
            let #(from, to) = parse_from_to(line)
            Builder(b.all, Some(ResourceMap(from: from, to: to, ranges: [])))
          }
          Some(resource_map), True -> {
            let #(from, to) = parse_from_to(line)
            Builder(
              [resource_map, ..b.all],
              Some(ResourceMap(from: from, to: to, ranges: [])),
            )
          }
          Some(ResourceMap(from: from, to: to, ranges: ranges)), False -> {
            let assert [dest, src, len] =
              string.split(line, " ")
              |> list.map(cint.parse_int_exn)
            Builder(
              b.all,
              Some(ResourceMap(
                from: from,
                to: to,
                ranges: [Range(src, dest, len), ..ranges],
              )),
            )
          }
        }
      },
    )
  let assert Some(final) = parsed.partial
  [final, ..parsed.all]
  |> list.reverse
}

pub fn pairs(list: List(a)) -> List(#(a, a)) {
  case list {
    [] -> []
    [_] -> panic as "odd el list"
    [x, y, ..rest] -> [#(x, y), ..pairs(rest)]
  }
}
