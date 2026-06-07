import core/game/board
import gleam/int
import gleam/list

pub fn are_adjacent_cell_indices_test() {
  let board4 = board.new(4)
  let range15 = int.range(15, -1, [], list.prepend)

  let expected_per_index = [
    [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0],
  ]

  list.zip(range15, expected_per_index)
  |> list.each(fn(zipped) {
    let #(source_index, expected) = zipped

    let received =
      list.map(range15, fn(dest_index) {
        case board.are_adjacent_cell_indices(board4, source_index, dest_index) {
          True -> 1
          False -> 0
        }
      })

    assert expected == received
  })
}

pub fn get_adjacent_cell_indices_test() {
  let board4 = board.new(4)
  let range15 = int.range(15, -1, [], list.prepend)

  let expected_per_index = [
    [1, 4],
    [0, 2, 5],
    [1, 3, 6],
    [2, 7],
    [0, 5, 8],
    [1, 4, 6, 9],
    [2, 5, 7, 10],
    [3, 6, 11],
    [4, 9, 12],
    [5, 8, 10, 13],
    [6, 9, 11, 14],
    [7, 10, 15],
    [8, 13],
    [9, 12, 14],
    [10, 13, 15],
    [11, 14],
  ]

  list.zip(range15, expected_per_index)
  |> list.each(fn(zipped) {
    let #(index, expected) = zipped
    assert expected == board.get_adjacent_cell_indices(board4, index)
  })
}

pub fn are_diagonal_cell_indices_test() {
  let board4 = board.new(4)
  let range15 = int.range(15, -1, [], list.prepend)

  let expected_per_index = [
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
    [0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0],
    [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
  ]

  list.zip(range15, expected_per_index)
  |> list.each(fn(zipped) {
    let #(source_index, expected) = zipped

    let received =
      list.map(range15, fn(dest_index) {
        case board.are_diagonal_cell_indices(board4, source_index, dest_index) {
          True -> 1
          False -> 0
        }
      })

    assert expected == received
  })
}

pub fn get_diagonal_cell_indices_test() {
  let board4 = board.new(4)
  let range15 = int.range(15, -1, [], list.prepend)

  let expected_per_index = [
    [5],
    [4, 6],
    [5, 7],
    [6],
    [1, 9],
    [0, 2, 8, 10],
    [1, 3, 9, 11],
    [2, 10],
    [5, 13],
    [4, 6, 12, 14],
    [5, 7, 13, 15],
    [6, 14],
    [9],
    [8, 10],
    [9, 11],
    [10],
  ]

  list.zip(range15, expected_per_index)
  |> list.each(fn(zipped) {
    let #(index, expected) = zipped
    assert expected == board.get_diagonal_cell_indices(board4, index)
  })
}
