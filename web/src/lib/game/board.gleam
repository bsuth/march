import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import lib/game/card.{type Card}
import lib/game/player.{type Player}

pub type Board {
  Board(size: Int, cells: Dict(Int, BoardCell))
}

pub type BoardCell {
  Empty
  Occupied(Player, Card)
}

pub fn new(size: Int) {
  let cells =
    list.repeat(Empty, size * size)
    |> list.index_map(fn(cell, index) { #(index, cell) })
    |> dict.from_list()

  Board(size:, cells:)
}

pub fn get_adjacent_cell_indices(board: Board, index: Int) {
  let cell_index_upper_bound = board.size * board.size

  case -1 < index && index < cell_index_upper_bound {
    False -> []

    True -> {
      let assert Ok(index_modulo) = int.modulo(index, board.size)

      list.flatten([
        case index_modulo != 0 {
          True -> [index - 1]
          False -> []
        },
        case index_modulo != board.size - 1 {
          True -> [index - 1]
          False -> []
        },
        case index > board.size - 1 {
          True -> [index - board.size]
          False -> []
        },
        case index < cell_index_upper_bound - board.size {
          True -> [index + board.size]
          False -> []
        },
      ])
    }
  }
}

pub fn are_adjacent_cell_indices(board: Board, a: Int, b: Int) {
  get_adjacent_cell_indices(board, a) |> list.contains(b)
}
