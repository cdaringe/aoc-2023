pub fn of_tuple2(x: #(a, a)) -> List(a) {
  [x.0, x.1]
}

pub fn of_tuple3(x: #(a, a, a)) -> List(a) {
  [x.0, x.1, x.2]
}

pub fn first_exn(x) {
  case x {
    [y] -> y
    _ -> panic as "expected array of length one"
  }
}
