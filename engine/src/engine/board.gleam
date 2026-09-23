import engine/card.{type Card}
import engine/settings.{type Settings}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import yuzu

pub type Board =
  Dict(Int, Option(Card))

pub fn new(settings: Settings) {
  int.range(0, settings.width * settings.height, dict.new(), fn(cards, index) {
    dict.insert(cards, index, option.None)
  })
}

pub fn insert_many(board: Board, entries: List(#(Int, Option(Card)))) {
  list.fold(entries, board, fn(cards, entry) {
    dict.insert(cards, entry.0, entry.1)
  })
}

pub fn insert_one(board: Board, entry: #(Int, Option(Card))) {
  dict.insert(board, entry.0, entry.1)
}

pub fn move_many(board: Board, moves: List(#(Int, Int))) {
  list.fold(moves, board, fn(board, move) { move_one(board, move) })
}

pub fn move_one(board: Board, move: #(Int, Int)) {
  let assert Ok(move_card) = dict.get(board, move.0)

  board
  |> dict.insert(move.1, move_card)
  |> dict.insert(move.0, option.None)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(board: Board) {
  json.dict(board, int.to_string, json.nullable(_, card.json))
}

pub fn decoder() {
  decode.dict(
    decode.then(decode.string, fn(key) {
      case int.parse(key) {
        Ok(index) -> decode.success(index)
        Error(_) -> decode.failure(0, "card index")
      }
    }),
    decode.optional(card.decoder()),
  )
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
  case dict.get(board, index) {
    Ok(option.None) -> callback()
    _ -> default_return_value
  }
}

pub fn use_some(
  board: Board,
  index: Int,
  default_return_value: return_value,
  callback: fn(Card) -> return_value,
) {
  case dict.get(board, index) {
    Ok(option.Some(card)) -> callback(card)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn is_none(board: Board, index: Int) {
  case dict.get(board, index) {
    Ok(option.None) -> True
    _ -> False
  }
}

pub fn is_some(board: Board, index: Int) {
  case dict.get(board, index) {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

pub fn is_occupied(board: Board, index: Int, player_index: Int) {
  case dict.get(board, index) {
    Ok(option.Some(card)) -> card.player_index == player_index
    _ -> False
  }
}

pub fn get_base_index(settings: Settings, player_index: Int) {
  case settings.doubles, player_index {
    False, 1 -> settings.width * settings.height - 1
    True, 3 -> settings.width * { settings.height - 1 }
    True, 2 -> settings.width * settings.height - 1
    True, 1 -> settings.width - 1
    _, _ -> 0
  }
}

pub fn get_up_index(settings: Settings, index: Int) {
  case index > settings.width - 1 {
    True -> option.Some(index - settings.width)
    False -> option.None
  }
}

pub fn get_down_index(settings: Settings, index: Int) {
  case index < settings.width * { settings.height - 1 } {
    True -> option.Some(index + settings.width)
    False -> option.None
  }
}

pub fn get_left_index(settings: Settings, index: Int) {
  case index % settings.width != 0 {
    True -> option.Some(index - 1)
    False -> option.None
  }
}

pub fn get_right_index(settings: Settings, index: Int) {
  case index % settings.width != settings.width - 1 {
    True -> option.Some(index + 1)
    False -> option.None
  }
}

pub fn get_all_up_indices(settings: Settings, index: Int) {
  use up_index <- yuzu.some(get_up_index(settings, index), [])
  get_all_up_indices(settings, up_index) |> list.prepend(up_index)
}

pub fn get_all_down_indices(settings: Settings, index: Int) {
  use down_index <- yuzu.some(get_down_index(settings, index), [])
  get_all_down_indices(settings, down_index) |> list.prepend(down_index)
}

pub fn get_all_left_indices(settings: Settings, index: Int) {
  use left_index <- yuzu.some(get_left_index(settings, index), [])
  get_all_left_indices(settings, left_index) |> list.prepend(left_index)
}

pub fn get_all_right_indices(settings: Settings, index: Int) {
  use right_index <- yuzu.some(get_right_index(settings, index), [])
  get_all_right_indices(settings, right_index) |> list.prepend(right_index)
}

pub fn get_adjacent_indices(settings: Settings, index: Int) {
  use <- yuzu.true(-1 < index && index < settings.width * settings.height, [])

  list.flatten([
    case get_up_index(settings, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_down_index(settings, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_left_index(settings, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_right_index(settings, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_diagonal_indices(settings: Settings, index: Int) {
  let index_upper_bound = settings.width * settings.height

  use <- yuzu.true(-1 < index && index < index_upper_bound, [])

  let column_index = index % settings.width

  let can_move_up = index > settings.width - 1
  let can_move_down = index < index_upper_bound - settings.width
  let can_move_left = column_index != 0
  let can_move_right = column_index != settings.width - 1

  list.flatten([
    case can_move_up && can_move_left {
      True -> [index - 1 - settings.width]
      False -> []
    },
    case can_move_up && can_move_right {
      True -> [index + 1 - settings.width]
      False -> []
    },
    case can_move_down && can_move_left {
      True -> [index - 1 + settings.width]
      False -> []
    },
    case can_move_down && can_move_right {
      True -> [index + 1 + settings.width]
      False -> []
    },
  ])
}

pub fn get_jump_up_index(settings: Settings, index: Int) {
  case index > 2 * settings.width - 1 {
    True -> option.Some(index - 2 * settings.width)
    False -> option.None
  }
}

pub fn get_jump_down_index(settings: Settings, index: Int) {
  case index < settings.width * { settings.height - 2 } {
    True -> option.Some(index + 2 * settings.width)
    False -> option.None
  }
}

pub fn get_jump_left_index(settings: Settings, index: Int) {
  case index % settings.width > 1 {
    True -> option.Some(index - 2)
    False -> option.None
  }
}

pub fn get_jump_right_index(settings: Settings, index: Int) {
  case index % settings.width < settings.width - 2 {
    True -> option.Some(index + 2)
    False -> option.None
  }
}

pub fn get_jump_indices(settings: Settings, index: Int) {
  use <- yuzu.true(-1 < index && index < settings.width * settings.height, [])

  list.flatten([
    case get_jump_up_index(settings, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_jump_down_index(settings, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_jump_left_index(settings, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_jump_right_index(settings, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}

pub fn get_mobius_up_index(settings: Settings, index: Int) {
  case index < settings.width {
    True -> option.Some(settings.width * { settings.height - 1 } + index)
    False -> option.None
  }
}

pub fn get_mobius_down_index(settings: Settings, index: Int) {
  case index > settings.width * { settings.height - 1 } - 1 {
    True -> option.Some(index % settings.width)
    False -> option.None
  }
}

pub fn get_mobius_left_index(settings: Settings, index: Int) {
  case index % settings.width == 0 {
    True -> option.Some(index + settings.width - 1)
    False -> option.None
  }
}

pub fn get_mobius_right_index(settings: Settings, index: Int) {
  case index % settings.width == settings.width - 1 {
    True -> option.Some(index - settings.width + 1)
    False -> option.None
  }
}

pub fn get_mobius_indices(settings: Settings, index: Int) {
  use <- yuzu.true(-1 < index && index < settings.width * settings.height, [])

  list.flatten([
    case get_mobius_up_index(settings, index) {
      option.Some(up_index) -> [up_index]
      option.None -> []
    },
    case get_mobius_down_index(settings, index) {
      option.Some(down_index) -> [down_index]
      option.None -> []
    },
    case get_mobius_left_index(settings, index) {
      option.Some(left_index) -> [left_index]
      option.None -> []
    },
    case get_mobius_right_index(settings, index) {
      option.Some(right_index) -> [right_index]
      option.None -> []
    },
  ])
}
