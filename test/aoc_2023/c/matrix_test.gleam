import gleeunit/should
import aoc_2023/c/matrix

const m1 = [1, 2, 3, 4, 5, 6]

pub fn matrix_of_list_test() {
  should.equal(matrix.of_list(m1, 2), [[1, 2], [3, 4], [5, 6]])
}
