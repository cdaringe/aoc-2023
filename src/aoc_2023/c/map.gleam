import gleam/map

pub fn upsert(m: map.Map(a, b), key: a, def: b, update_fn: fn(b) -> b) {
  case map.get(m, key) {
    Ok(v) -> map.insert(m, key, update_fn(v))
    Error(Nil) -> map.insert(m, key, def)
  }
}
