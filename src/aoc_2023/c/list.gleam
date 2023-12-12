import gleam/list
import gleam/iterator as it

pub fn of_tuple2(x: #(a, a)) -> List(a) {
  [x.0, x.1]
}

pub fn of_tuple3(x: #(a, a, a)) -> List(a) {
  [x.0, x.1, x.2]
}

pub fn first_exn(x) {
  case x {
    [y, ..] -> y
    _ -> panic as "expected array of length one"
  }
}

pub fn last_exn(x) {
  case list.last(x) {
    Ok(it) -> it
    _ -> panic as "invalid end of list"
  }
}

pub fn with_window_2(els, map) {
  case els {
    [a, b] -> map(a, b)
    _ -> panic as "invalid window"
  }
}

pub fn find_index(list: List(a), cb) -> Result(#(a, Int), Nil) {
  it.zip(it.from_list(list), it.range(0, list.length(list) - 1))
  |> it.find(fn(pair) { cb(pair.0, pair.1) })
}

// let find_mapi f l =
//   let rec aux f i = function
//     | [] -> None
//     | x :: l' ->
//       (match f i x with
//       | Some _ as res -> res
//       | None -> aux f (i + 1) l')
//   in
//   aux f 0 l

fn find_map_index_inner(l, f, i) {
  case l {
    [] -> Error(Nil)
    [hd, ..tail] ->
      case f(hd, i) {
        Ok(_) as res -> res
        Error(_) -> find_map_index_inner(tail, f, i + 1)
      }
  }
}

pub fn find_map_index(
  list: List(a),
  cb: fn(a, Int) -> Result(b, Nil),
) -> Result(b, Nil) {
  find_map_index_inner(list, cb, 0)
}
