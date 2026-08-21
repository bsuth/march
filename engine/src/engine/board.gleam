import engine/board/cell.{type Cell, Cell}
import engine/board/tile
import engine/card.{type Card}
import engine/color.{type Color}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import yuzu

pub type Board {
  Board(width: Int, height: Int, cells: Dict(Int, Cell))
}

pub fn new(width: Int, height: Int) {
  Board(
    width:,
    height:,
    cells: int.range(0, width * height, dict.new(), fn(cells, index) {
      dict.insert(
        cells,
        index,
        Cell(index:, tile: tile.Normal, card: option.None),
      )
    }),
  )
}

pub fn update(board: Board, cells: List(Cell)) {
  Board(
    ..board,
    cells: list.fold(cells, board.cells, fn(cells, cell) {
      dict.insert(cells, cell.index, cell)
    }),
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(board: Board) {
  json.object([
    #("width", json.int(board.width)),
    #("height", json.int(board.height)),
    #("cells", json.dict(board.cells, int.to_string, cell.json)),
  ])
}

pub fn decoder() {
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)

  use cells <- decode.field(
    "cells",
    decode.dict(
      decode.then(decode.string, fn(key) {
        case int.parse(key) {
          Ok(index) -> decode.success(index)
          Error(_) -> decode.failure(0, "cell index")
        }
      }),
      cell.decoder(),
    ),
  )

  decode.success(Board(width:, height:, cells:))
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_cell(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn(Cell) -> return_value,
) {
  case dict.get(board.cells, index) {
    Ok(cell) -> callback(cell)
    _ -> default_return_value
  }
}

pub fn use_none(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case dict.get(board.cells, index) {
    Ok(Cell(_, _, card: option.None)) -> callback()
    _ -> default_return_value
  }
}

pub fn use_some(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn(Card) -> return_value,
) {
  case dict.get(board.cells, index) {
    Ok(Cell(_, _, card: option.Some(card))) -> callback(card)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn is_none(board: Board, index: Int) {
  case dict.get(board.cells, index) {
    Ok(Cell(_, _, option.None)) -> True
    _ -> False
  }
}

pub fn is_some(board: Board, index: Int) {
  case dict.get(board.cells, index) {
    Ok(Cell(_, _, option.Some(_))) -> True
    _ -> False
  }
}

pub fn get_base_index(board: Board, color: Color) {
  case color {
    color.Black -> 0
    color.White -> board.width * board.height - 1
  }
}

pub fn get_up_cell_index(board: Board, index: Int) {
  case index > board.width - 1 {
    True -> option.Some(index - board.width)
    False -> option.None
  }
}

pub fn get_down_cell_index(board: Board, index: Int) {
  case index < board.width * { board.height - 1 } {
    True -> option.Some(index + board.width)
    False -> option.None
  }
}

pub fn get_left_cell_index(board: Board, index: Int) {
  case index % board.width != 0 {
    True -> option.Some(index - 1)
    False -> option.None
  }
}

pub fn get_right_cell_index(board: Board, index: Int) {
  case index % board.width != board.width - 1 {
    True -> option.Some(index + 1)
    False -> option.None
  }
}

pub fn get_all_up_cell_indices(board: Board, index: Int) {
  use up_index <- yuzu.some(get_up_cell_index(board, index), [])
  get_all_up_cell_indices(board, up_index) |> list.prepend(up_index)
}

pub fn get_all_down_cell_indices(board: Board, index: Int) {
  use down_index <- yuzu.some(get_down_cell_index(board, index), [])
  get_all_down_cell_indices(board, down_index) |> list.prepend(down_index)
}

pub fn get_all_left_cell_indices(board: Board, index: Int) {
  use left_index <- yuzu.some(get_left_cell_index(board, index), [])
  get_all_left_cell_indices(board, left_index) |> list.prepend(left_index)
}

pub fn get_all_right_cell_indices(board: Board, index: Int) {
  use right_index <- yuzu.some(get_right_cell_index(board, index), [])
  get_all_right_cell_indices(board, right_index) |> list.prepend(right_index)
}

pub fn get_adjacent_cell_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_up_cell_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_down_cell_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_left_cell_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_right_cell_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_diagonal_cell_indices(board: Board, index: Int) {
  let cell_index_upper_bound = board.width * board.height

  use <- yuzu.true(-1 < index && index < cell_index_upper_bound, [])

  let column_index = index % board.width

  let can_move_up = index > board.width - 1
  let can_move_down = index < cell_index_upper_bound - board.width
  let can_move_left = column_index != 0
  let can_move_right = column_index != board.width - 1

  list.flatten([
    case can_move_up && can_move_left {
      True -> [index - 1 - board.width]
      False -> []
    },
    case can_move_up && can_move_right {
      True -> [index + 1 - board.width]
      False -> []
    },
    case can_move_down && can_move_left {
      True -> [index - 1 + board.width]
      False -> []
    },
    case can_move_down && can_move_right {
      True -> [index + 1 + board.width]
      False -> []
    },
  ])
}

pub fn get_jump_up_cell_index(board: Board, index: Int) {
  case index > 2 * board.width - 1 {
    True -> option.Some(index - 2 * board.width)
    False -> option.None
  }
}

pub fn get_jump_down_cell_index(board: Board, index: Int) {
  case index < board.width * { board.height - 2 } {
    True -> option.Some(index + 2 * board.width)
    False -> option.None
  }
}

pub fn get_jump_left_cell_index(board: Board, index: Int) {
  case index % board.width > 1 {
    True -> option.Some(index - 2)
    False -> option.None
  }
}

pub fn get_jump_right_cell_index(board: Board, index: Int) {
  case index % board.width < board.width - 2 {
    True -> option.Some(index + 2)
    False -> option.None
  }
}

pub fn get_jump_cell_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_jump_up_cell_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_jump_down_cell_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_jump_left_cell_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_jump_right_cell_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_mobius_up_cell_index(board: Board, index: Int) {
  case index < board.width {
    True -> option.Some(board.width * { board.height - 1 } + index)
    False -> option.None
  }
}

pub fn get_mobius_down_cell_index(board: Board, index: Int) {
  case index > board.width * { board.height - 1 } - 1 {
    True -> option.Some(index % board.width)
    False -> option.None
  }
}

pub fn get_mobius_left_cell_index(board: Board, index: Int) {
  case index % board.width == 0 {
    True -> option.Some(index + board.width - 1)
    False -> option.None
  }
}

pub fn get_mobius_right_cell_index(board: Board, index: Int) {
  case index % board.width == board.width - 1 {
    True -> option.Some(index - board.width + 1)
    False -> option.None
  }
}

pub fn get_mobius_cell_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_mobius_up_cell_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_mobius_down_cell_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_mobius_left_cell_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_mobius_right_cell_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_slide_up_cell_index(board: Board, index: Int) {
  get_slide_up_cell_index_(board, index - board.width)
}

fn get_slide_up_cell_index_(board: Board, index: Int) {
  use <- yuzu.true(-1 < index, option.None)
  use <- use_none(board, index, option.Some(index))
  use <- yuzu.none_(get_slide_up_cell_index(board, index - board.width))
  option.Some(index)
}

pub fn get_slide_down_cell_index(board: Board, index: Int) {
  get_slide_down_cell_index_(board, index + board.width)
}

fn get_slide_down_cell_index_(board: Board, index: Int) {
  use <- yuzu.true(index < board.width * board.height, option.None)
  use <- use_none(board, index, option.Some(index))
  use <- yuzu.none_(get_slide_down_cell_index(board, index + board.width))
  option.Some(index)
}

pub fn get_slide_left_cell_index(board: Board, index: Int) {
  get_slide_left_cell_index_(board, index - 1)
}

fn get_slide_left_cell_index_(board: Board, index: Int) {
  let column_index = index % board.width

  use <- yuzu.true(column_index != board.width - 1, option.None)
  use <- use_none(board, index, option.Some(index))
  use <- yuzu.none_(get_slide_left_cell_index(board, index - 1))

  option.Some(index)
}

pub fn get_slide_right_cell_index(board: Board, index: Int) {
  get_slide_right_cell_index_(board, index + 1)
}

fn get_slide_right_cell_index_(board: Board, index: Int) {
  let column_index = index % board.width

  use <- yuzu.true(column_index != 0, option.None)
  use <- use_none(board, index, option.Some(index))
  use <- yuzu.none_(get_slide_right_cell_index(board, index + 1))

  option.Some(index)
}

pub fn get_slide_cell_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_slide_up_cell_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_slide_down_cell_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_slide_left_cell_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_slide_right_cell_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_teleport_up_cell_index(board: Board, index: Int) {
  get_teleport_up_cell_index_(board, index - board.width)
}

fn get_teleport_up_cell_index_(board: Board, index: Int) {
  use <- yuzu.true(-1 < index, option.None)
  use <- yuzu.none_(get_teleport_up_cell_index(board, index - board.width))
  use <- use_none(board, index, option.None)
  option.Some(index)
}

pub fn get_teleport_down_cell_index(board: Board, index: Int) {
  get_teleport_down_cell_index_(board, index + board.width)
}

fn get_teleport_down_cell_index_(board: Board, index: Int) {
  use <- yuzu.true(index < board.width * board.height, option.None)
  use <- yuzu.none_(get_teleport_down_cell_index(board, index + board.width))
  use <- use_none(board, index, option.None)
  option.Some(index)
}

pub fn get_teleport_left_cell_index(board: Board, index: Int) {
  get_teleport_left_cell_index_(board, index - 1)
}

fn get_teleport_left_cell_index_(board: Board, index: Int) {
  let column_index = index % board.width

  use <- yuzu.true(column_index != board.width - 1, option.None)
  use <- yuzu.none_(get_teleport_left_cell_index(board, index - 1))
  use <- use_none(board, index, option.None)

  option.Some(index)
}

pub fn get_teleport_right_cell_index(board: Board, index: Int) {
  get_teleport_right_cell_index_(board, index + 1)
}

fn get_teleport_right_cell_index_(board: Board, index: Int) {
  let column_index = index % board.width

  use <- yuzu.true(column_index != 0, option.None)
  use <- yuzu.none_(get_teleport_right_cell_index(board, index + 1))
  use <- use_none(board, index, option.None)

  option.Some(index)
}

pub fn get_teleport_cell_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_teleport_up_cell_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_teleport_down_cell_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_teleport_left_cell_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_teleport_right_cell_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}
