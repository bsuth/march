import engine/tile.{type Tile}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import yuzu

pub type Board {
  Board(width: Int, height: Int, tiles: Dict(Int, Tile))
}

pub fn normal(width: Int, height: Int) {
  Board(
    width:,
    height:,
    tiles: int.range(0, width * height, dict.new(), fn(cards, index) {
      dict.insert(cards, index, tile.Normal)
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
    #(
      "tiles",
      dict.to_list(board.tiles)
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(fn(entry) { entry.1 })
        |> json.array(tile.json),
    ),
  ])
}

pub fn decoder() {
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)

  use tiles <- decode.field("tiles", {
    tile.decoder()
    |> decode.list()
    |> decode.map(fn(positions) {
      positions
      |> list.index_map(fn(position, index) { #(index, position) })
      |> dict.from_list()
    })
  })

  decode.success(Board(width:, height:, tiles:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn get_up_index(board: Board, index: Int) {
  case index > board.width - 1 {
    True -> option.Some(index - board.width)
    False -> option.None
  }
}

pub fn get_down_index(board: Board, index: Int) {
  case index < board.width * { board.height - 1 } {
    True -> option.Some(index + board.width)
    False -> option.None
  }
}

pub fn get_left_index(board: Board, index: Int) {
  case index % board.width != 0 {
    True -> option.Some(index - 1)
    False -> option.None
  }
}

pub fn get_right_index(board: Board, index: Int) {
  case index % board.width != board.width - 1 {
    True -> option.Some(index + 1)
    False -> option.None
  }
}

pub fn get_all_up_indices(board: Board, index: Int) {
  use up_index <- yuzu.some(get_up_index(board, index), [])
  get_all_up_indices(board, up_index) |> list.prepend(up_index)
}

pub fn get_all_down_indices(board: Board, index: Int) {
  use down_index <- yuzu.some(get_down_index(board, index), [])
  get_all_down_indices(board, down_index) |> list.prepend(down_index)
}

pub fn get_all_left_indices(board: Board, index: Int) {
  use left_index <- yuzu.some(get_left_index(board, index), [])
  get_all_left_indices(board, left_index) |> list.prepend(left_index)
}

pub fn get_all_right_indices(board: Board, index: Int) {
  use right_index <- yuzu.some(get_right_index(board, index), [])
  get_all_right_indices(board, right_index) |> list.prepend(right_index)
}

pub fn get_adjacent_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_up_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_down_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_left_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_right_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_diagonal_indices(board: Board, index: Int) {
  let index_upper_bound = board.width * board.height

  use <- yuzu.true(-1 < index && index < index_upper_bound, [])

  let column_index = index % board.width

  let can_move_up = index > board.width - 1
  let can_move_down = index < index_upper_bound - board.width
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

pub fn get_jump_up_index(board: Board, index: Int) {
  case index > 2 * board.width - 1 {
    True -> option.Some(index - 2 * board.width)
    False -> option.None
  }
}

pub fn get_jump_down_index(board: Board, index: Int) {
  case index < board.width * { board.height - 2 } {
    True -> option.Some(index + 2 * board.width)
    False -> option.None
  }
}

pub fn get_jump_left_index(board: Board, index: Int) {
  case index % board.width > 1 {
    True -> option.Some(index - 2)
    False -> option.None
  }
}

pub fn get_jump_right_index(board: Board, index: Int) {
  case index % board.width < board.width - 2 {
    True -> option.Some(index + 2)
    False -> option.None
  }
}

pub fn get_jump_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_jump_up_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_jump_down_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_jump_left_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_jump_right_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_mobius_up_index(board: Board, index: Int) {
  case index < board.width {
    True -> option.Some(board.width * { board.height - 1 } + index)
    False -> option.None
  }
}

pub fn get_mobius_down_index(board: Board, index: Int) {
  case index > board.width * { board.height - 1 } - 1 {
    True -> option.Some(index % board.width)
    False -> option.None
  }
}

pub fn get_mobius_left_index(board: Board, index: Int) {
  case index % board.width == 0 {
    True -> option.Some(index + board.width - 1)
    False -> option.None
  }
}

pub fn get_mobius_right_index(board: Board, index: Int) {
  case index % board.width == board.width - 1 {
    True -> option.Some(index - board.width + 1)
    False -> option.None
  }
}

pub fn get_mobius_indices(board: Board, index: Int) {
  use <- yuzu.true(-1 < index && index < board.width * board.height, [])

  list.flatten([
    case get_mobius_up_index(board, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_mobius_down_index(board, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_mobius_left_index(board, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_mobius_right_index(board, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}
