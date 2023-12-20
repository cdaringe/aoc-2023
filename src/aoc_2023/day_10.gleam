import aoc_2023/common
import aoc_2023/c/pair
import aoc_2023/day_10/matrix.{
  type Coord, type Dir, Coord, Down, Left, Right, Up,
}
import gleam/list
import gleam/string
import gleam/bool
import gleam/map
import gleam/iterator
import gleam/io
import gleam/set
import gleam/result

pub type Pipe {
  HBar
  VBar
  TR
  TL
  BL
  BR
  Start
  Hole
}

pub type Air {
  Out
  Unk
}

pub type Env {
  Env(u: Air, r: Air, d: Air, l: Air)
}

pub type EnvPipe {
  EnvPipe(cv: CVP, env: Env)
}

type PipeGrid =
  matrix.Matrix(Pipe)

type CVP =
  matrix.CoordVal(Pipe)

pub fn pt_1(input: String) {
  let grid: PipeGrid =
    input
    |> parse
  let assert Ok(s) = matrix.find_cell(grid, fn(v) { v == Start })
  build_loop(grid, s)
  |> list.length
  |> fn(x) { x / 2 }
}

pub fn pt_2(input: String) {
  let grid = parse(input)
  let assert Ok(s) = matrix.find_cell(grid, fn(v) { v == Start })
  let loop = build_loop(grid, s)
  let loop_coords = list.map(loop, fn(cv) { cv.coord })
  let loop_coords_set = set.from_list(loop_coords)
  let envpipe_loop =
    grid
    |> unused_pipes_to_holes(loop_coords_set)
    |> to_envpipe_loop(loop, loop_coords_set)

  let mask_by_coord = flood_fill_out_all(grid, envpipe_loop)

  let mask_matrix_pass_2 =
    mask_by_coord
    |> fn(classified_by_coord) { unfilled_as_in(grid, classified_by_coord) }

  io.println(matrix.to_string(mask_matrix_pass_2, mask_to_string))

  8
}

fn parse(input: String) -> PipeGrid {
  input
  |> common.lines
  |> matrix.of_lines(parse_pipe)
}

fn nav(m: PipeGrid, last: CVP, current: CVP) -> CVP {
  matrix.get_neighbor_if(m, current.coord, fn(neighb: CVP) {
    use <- bool.guard(
      when: last.coord.x == neighb.coord.x
      && last.coord.y == neighb.coord.y,
      return: False,
    )
    can_connect(current, neighb)
  })
  |> common.expect("no neighbor found")
}

fn build_loop(matrix: PipeGrid, start: CVP) -> List(CVP) {
  let loopl =
    iterator.from_list([1])
    |> iterator.cycle
    |> iterator.fold_until(from: [start], with: fn(cvps: List(CVP), _) {
      let #(curr, last) = case cvps {
        [] -> panic as "bummer"
        [x] -> #(x, x)
        [x, y, ..] -> #(x, y)
      }
      let next = nav(matrix, last, curr)
      case next.val {
        Start -> list.Stop(cvps)
        _ -> list.Continue([next, ..cvps])
      }
    })
  loopl
}

fn get_dir(p1: CVP, p2: CVP) {
  let dx = p2.coord.x - p1.coord.x
  let dy = p2.coord.y - p1.coord.y
  case dx, dy {
    1, _ -> Right
    _, 1 -> Down
    -1, _ -> Left
    _, -1 -> Up
    _, _ -> panic as "invalid dir"
  }
}

fn has_mate(pipe: Pipe, dir: Dir) {
  case pipe, dir {
    Start, _ -> True
    HBar, Left -> True
    HBar, Right -> True
    VBar, Up -> True
    VBar, Down -> True
    TL, Right -> True
    TL, Down -> True
    TR, Left -> True
    TR, Down -> True
    BR, Left -> True
    BR, Up -> True
    BL, Right -> True
    BL, Up -> True
    _, _ -> False
  }
}

fn invert_dir(dir: Dir) {
  case dir {
    Up -> Down
    Left -> Right
    Right -> Left
    Down -> Up
  }
}

fn can_connect(p1: CVP, p2: CVP) {
  let dir = get_dir(p1, p2)
  let m1 = has_mate(p1.val, dir)
  let m2 = has_mate(p2.val, invert_dir(dir))
  let ok = m1 && m2 && m1 == m2
  ok
}

fn parse_pipe(it: String) -> Pipe {
  case it {
    "-" -> HBar
    "|" -> VBar
    "F" -> TL
    "7" -> TR
    "J" -> BR
    "L" -> BL
    "." -> Hole
    "S" -> Start
    _ -> panic as "bad pipe part"
  }
}

fn unused_pipes_to_holes(grid: PipeGrid, loop_coords_set) -> PipeGrid {
  matrix.map(grid, fn(cv) {
    case set.contains(loop_coords_set, cv.coord) {
      True -> cv.val
      False -> Hole
    }
  })
}

//
// workaroudn while debug, make S the first start cell
// in the input all of the time
//
fn to_envpipe_loop(
  _grid: PipeGrid,
  loop: List(CVP),
  _loop_coords_set,
) -> List(EnvPipe) {
  io.debug(#("warn S must be in TL corner"))
  // let cv0: CVP = matrix.find_exn(grid, fn(cv) { set.contains(loop_coords_set, cv.coord) })
  // let air_of_env0 = fn(dir) {
  //   case cv0.val, dir {
  //     // exception cases
  //     VBar, Up -> Unk
  //     BL, Up -> Unk
  //     BR, Up -> Unk
  //     _, Up -> Out
  //     _, Left -> Out
  //     _, _ -> Unk
  //   }
  // }
  // let env: Env =
  //   Env(u: air_of_env0(Up), d: air_of_env0(Down), r: air_of_env0(Right), l: Unk)

  // let out_count =
  //   fold_env(
  //     env,
  //     0,
  //     fn(total, air, _) {
  //       total + case air {
  //         Out -> 1
  //         _ -> 0
  //       }
  //     },
  //   )

  // case out_count {
  //   0 | 1 -> Nil
  //   n -> {
  //     io.println(env_to_string(env))
  //     io.debug(#("found too many outs", n))
  //     panic
  //   }
  // }
  // let envpipe0 = EnvPipe(cv: cv0, env: env)

  // let subloops =
  //   list.split_while(loop, fn(it) { it.coord == envpipe0.cv.coord })
  // let next_loop = list.append(subloops.1, subloops.0)
  // io.debug(#("next_loop", next_loop))

  let assert [cv0, ..rest] = loop
  let envpipe0 = EnvPipe(cv: cv0, env: Env(u: Out, l: Out, d: Unk, r: Unk))

  let state = #([], envpipe0)
  [
    envpipe0,
    ..{
      list.fold(rest, state, fn(state, cv) {
        let #(all, last) = state
        let env = permute_env_cw(last, cv)
        let envpipe = EnvPipe(cv: cv, env: env)
        #([envpipe, ..all], envpipe)
      })
      |> pair.first
      |> list.reverse
    }
  ]
}

// fn swap_start(l) {
//   let assert Ok(last) = list.last(l)
//   let assert Ok(snd) = list.at(l, 1)
//   case last.val, snd.val {
//     Start, _ | _, Start -> panic
//   }
//   // HBar
//   // VBar
//   // TR
//   // TL
//   // BL
//   // BR
// }

fn air_to_string(air: Air) {
  case air {
    Out -> "O"
    Unk -> "?"
  }
}

// fn air_of_dir(env: Env, dir: Dir) -> Air {
//   case dir {
//     Up -> env.u
//     Down -> env.d
//     Right -> env.r
//     Left -> env.l
//   }
// }

// fn is_collinear(a, b) {
//   case a, b {
//     Up, Up -> True
//     Up, Down -> True
//     Down, Down -> True
//     Down, Up -> True

//     Left, Left -> True
//     Left, Right -> True
//     Right, Right -> True
//     Right, Left -> True

//     _, _ -> False
//   }
// }

fn permute_env_cw(last: EnvPipe, cv: CVP) -> Env {
  let dir = get_dir(last.cv, cv)
  let env = empty_env()
  case dir, cv.val {
    _, Start -> panic as "start should not be visited"
    Right, TR -> Env(..env, u: Out, r: Out)
    Right, BR -> Env(..env, d: Out, r: Out)
    Right, HBar -> Env(..env, u: Out)

    Left, TL -> Env(..env, d: Out, r: Out)
    Left, BL -> Env(..env, d: Out, l: Out)
    Left, HBar -> Env(..env, d: Out)

    Up, VBar -> Env(..env, l: Out)
    Up, TR -> Env(..env, l: Out, d: Out)
    Up, TL -> Env(..env, l: Out, u: Out)

    Down, VBar -> Env(..env, r: Out)
    Down, BR -> Env(..env, d: Out, r: Out)
    Down, BL -> Env(..env, u: Out, r: Out)

    _, _ -> {
      io.debug(#("invalid move", dir, cv.val))
      panic
    }
  }
}

// fn permute_env_cw(last: EnvPipe, cv: CVP) -> Env {
//   let dir = get_dir(last.cv, cv)
//   // carry the outside air on top on either side of the direction, but no co-lin
//   // e.g., assuming left to right
//   //  O   O
//   // --- --| , or, └─- ---
//   //                O   O
//   let e0 =
//     fold_env(
//       last.env,
//       empty_env(),
//       fn(env, prior_air, rel_dir) {
//         let is_col = is_collinear(dir, rel_dir)
//         io.debug(#(prior_air, dir, is_col))
//         case prior_air, rel_dir, is_col {
//           Out, Up, False -> Env(..env, u: Out)
//           Out, Down, False -> Env(..env, d: Out)
//           Out, Left, False -> Env(..env, l: Out)
//           Out, Right, False -> Env(..env, r: Out)
//           _, _, _ -> env
//         }
//       },
//     )
//   io.debug(#(" permute 1", env_to_string(last.env), dir, env_to_string(e0)))
//   // panic
//   let rot = case cv.val, dir {
//     BR, Right -> CCW
//     BR, Down -> CW
//     TR, Right -> CW
//     TR, Up -> CCW
//     BL, Left -> CW
//     BL, Down -> CCW
//     TL, Left -> CCW
//     TL, Up -> CW
//     _, _ -> Pin
//   }
//   let rot_env = case rot {
//     CCW -> env_ccw(last.env)
//     CW -> env_cw(last.env)
//     _ -> last.env
//   }
//   let either_out = fn(a, b) {
//     case a, b {
//       a, _ if a == Out -> Out
//       _, b if b == Out -> Out
//       _, _ -> Unk
//     }
//   }
//   let final_env =
//     Env(
//       u: either_out(e0.u, rot_env.u),
//       r: either_out(e0.r, rot_env.r),
//       d: either_out(e0.d, rot_env.d),
//       l: either_out(e0.l, rot_env.l),
//     )
//   io.debug(#(" permute 2", env_to_string(e0), dir, env_to_string(final_env)))

//   final_env
// }

// type Rot {
//   CCW
//   CW
//   Pin
// }

fn empty_env() {
  Env(u: Unk, r: Unk, d: Unk, l: Unk)
}

// fn empty_envpipe(cv: CVP) {
//   EnvPipe(cv: cv, env: empty_env())
// }

// fn pipe_to_string(pipe: Pipe) {
//   case pipe {
//     HBar -> "-"
//     VBar -> "|"
//     TR -> "7"
//     TL -> "F"
//     BL -> "L"
//     BR -> "J"
//     Start -> "S"
//     Hole -> "."
//   }
// }

pub type Mask {
  MOut
  MPipe
  MIn
}

type MaskByCoord =
  map.Map(matrix.Coord, Mask)

fn mask_to_string(mask: Mask) {
  case mask {
    MOut -> "O"
    MPipe -> "P"
    MIn -> "I"
  }
}

pub fn flood_fill_out(
  grid: PipeGrid,
  coord: matrix.Coord,
  classified: MaskByCoord,
) {
  let existing = map.get(classified, coord)
  use <- bool.guard(result.is_ok(existing), classified)
  case matrix.get_cell(grid, coord) {
    Ok(val) -> {
      case val {
        Hole -> {
          let next_classifed = map.insert(classified, coord, MOut)
          matrix.fold_adjacent(grid, coord, next_classifed, fn(
            next_classifed,
            _pipe,
            next_coord,
          ) {
            flood_fill_out(grid, next_coord, next_classifed)
          })
        }
        _ -> map.insert(classified, coord, MPipe)
      }
    }
    Error(Nil) -> classified
  }
}

pub fn flood_fill_out_all(grid: PipeGrid, envpipes: List(EnvPipe)) {
  use classified, envpipe <- list.fold(envpipes, map.new())
  io.debug(#("ffoa", envpipe.cv.val, env_to_string(envpipe.env)))
  fold_envpipe(envpipe, classified, fn(classified, _envpipe, coord, air, _) {
    case air {
      Out -> flood_fill_out(grid, coord, classified)
      _ -> classified
    }
  })
}

fn unfilled_as_in(
  grid: PipeGrid,
  classified: MaskByCoord,
) -> matrix.Matrix(Mask) {
  matrix.map(grid, fn(cv) {
    case map.get(classified, cv.coord) {
      Ok(kind) -> kind
      Error(Nil) -> MIn
    }
  })
}

// pub fn to_air_islands(grid: PipeGrid, loop_coords_set, pipenv_loop) {
//   use state, cv <- matrix.fold(grid, #(-1, map.new()))
//   let #(max_island_id, island_id_by_coord) = state
//   let matrix.CoordVal(coord, val) = cv
//   case map.has_key(island_id_by_coord, cv.coord) {
//     True -> state
//     False -> {
//       let island_id = max_island_id + 1

//       #(island_id, island_id_by_coord)
//     }
//   }
// }
fn env_as_list(env: Env) {
  [#(env.u, Up), #(env.r, Right), #(env.d, Down), #(env.l, Left)]
}

fn fold_env(env: Env, init: a, with cb: fn(a, Air, Dir) -> a) -> a {
  env
  |> env_as_list
  |> list.fold(init, fn(acc, it) {
    let #(air, dir) = it
    cb(acc, air, dir)
  })
}

fn fold_envpipe(
  envpipe: EnvPipe,
  init: a,
  with cb: fn(a, EnvPipe, Coord, Air, Dir) -> a,
) -> a {
  let EnvPipe(cv: epcv, env: env) = envpipe
  env
  |> env_as_list
  |> list.fold(init, fn(acc, it) {
    let #(air, dir) = it
    let #(dx, dy) = case dir {
      Up -> #(0, -1)
      Down -> #(0, 1)
      Left -> #(-1, 0)
      Right -> #(0, 1)
    }
    cb(acc, envpipe, Coord(x: epcv.coord.x + dx, y: epcv.coord.y + dy), air, dir,
    )
  })
}

fn dir_to_string(dir: Dir) {
  case dir {
    Up -> "u"
    Right -> "r"
    Down -> "d"
    Left -> "l"
  }
}

fn env_to_string(env: Env) {
  fold_env(env, [], fn(acc, air, dir) {
    [dir_to_string(dir) <> " " <> air_to_string(air), ..acc]
  })
  |> string.join(", ")
}
