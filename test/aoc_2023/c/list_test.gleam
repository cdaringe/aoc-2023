import gleeunit/should
import aoc_2023/c/list.{of_tuple2, of_tuple3}

pub fn of_tuple_test() {
  should.equal(of_tuple2(#(1, 2)), [1, 2])
  should.equal(of_tuple3(#(1, 2, 3)), [1, 2, 3])
  should.equal(of_tuple3(#("1", "2", "c")), ["1", "2", "c"])
}
