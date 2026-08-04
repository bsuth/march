import engine/unit.{type Unit}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import yuzu

pub type Board {
  Board(size: Int, cells: Dict(Int, Option(Unit)))
}

pub fn new(size: Int) {
  Board(
    size:,
    cells: list.repeat(option.None, size * size)
      |> list.index_map(fn(cell, index) { #(index, cell) })
      |> dict.from_list(),
  )
}

pub fn update(board: Board, updates: List(#(Int, Option(Unit)))) {
  Board(
    ..board,
    cells: list.fold(updates, board.cells, fn(cells, update) {
      dict.insert(cells, update.0, update.1)
    }),
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(board: Board) {
  json.object([
    #("size", json.int(board.size)),
    #(
      "cells",
      json.dict(board.cells, int.to_string, fn(cell) {
        case cell {
          option.Some(unit) -> unit.json(unit)
          option.None -> json.null()
        }
      }),
    ),
  ])
}

pub fn decoder() {
  use size <- decode.field("size", decode.int)

  use cells <- decode.field(
    "cells",
    decode.dict(
      decode.then(decode.string, fn(key) {
        case int.parse(key) {
          Ok(index) -> decode.success(index)
          Error(_) -> decode.failure(0, "cell index")
        }
      }),
      decode.optional(unit.decoder()),
    ),
  )

  decode.success(Board(size:, cells:))
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_none(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case dict.get(board.cells, index) {
    Ok(option.None) -> callback()
    _ -> default_return_value
  }
}

pub fn use_some(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn(Unit) -> return_value,
) {
  case dict.get(board.cells, index) {
    Ok(option.Some(unit)) -> callback(unit)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn is_none(board: Board, index: Int) {
  case dict.get(board.cells, index) {
    Ok(option.None) -> True
    _ -> False
  }
}

pub fn is_some(board: Board, index: Int) {
  case dict.get(board.cells, index) {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

pub fn are_adjacent_cell_indices(board: Board, a: Int, b: Int) {
  get_adjacent_cell_indices(board, a) |> list.contains(b)
}

pub fn get_adjacent_cell_indices(board: Board, index: Int) {
  let cell_index_upper_bound = board.size * board.size

  use <- yuzu.true(-1 < index && index < cell_index_upper_bound, [])
  use index_modulo <- yuzu.ok(int.modulo(index, board.size), [])

  let can_move_up = index > board.size - 1
  let can_move_down = index < cell_index_upper_bound - board.size
  let can_move_left = index_modulo != 0
  let can_move_right = index_modulo != board.size - 1

  list.flatten([
    case can_move_up {
      True -> [index - board.size]
      False -> []
    },
    case can_move_left {
      True -> [index - 1]
      False -> []
    },
    case can_move_right {
      True -> [index + 1]
      False -> []
    },
    case can_move_down {
      True -> [index + board.size]
      False -> []
    },
  ])
}

pub fn are_diagonal_cell_indices(board: Board, a: Int, b: Int) {
  get_diagonal_cell_indices(board, a) |> list.contains(b)
}

pub fn get_diagonal_cell_indices(board: Board, index: Int) {
  let cell_index_upper_bound = board.size * board.size

  use <- yuzu.true(-1 < index && index < cell_index_upper_bound, [])
  use index_modulo <- yuzu.ok(int.modulo(index, board.size), [])

  let can_move_up = index > board.size - 1
  let can_move_down = index < cell_index_upper_bound - board.size
  let can_move_left = index_modulo != 0
  let can_move_right = index_modulo != board.size - 1

  list.flatten([
    case can_move_up && can_move_left {
      True -> [index - 1 - board.size]
      False -> []
    },
    case can_move_up && can_move_right {
      True -> [index + 1 - board.size]
      False -> []
    },
    case can_move_down && can_move_left {
      True -> [index - 1 + board.size]
      False -> []
    },
    case can_move_down && can_move_right {
      True -> [index + 1 + board.size]
      False -> []
    },
  ])
}
