import gleam/int

pub fn parse_int_exn(x: String) {
  let assert Ok(y) = int.parse(x)
  y
}
