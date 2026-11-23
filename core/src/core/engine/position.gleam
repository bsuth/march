import core/engine/board.{type Board}
import core/engine/position_card.{type PositionCard}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}

pub type Position =
  Dict(Int, Option(PositionCard))

pub fn new(board: Board) {
  int.range(0, board.width * board.height, dict.new(), fn(position, index) {
    dict.insert(position, index, option.None)
  })
}

pub fn insert_many(
  position: Position,
  entries: List(#(Int, Option(PositionCard))),
) {
  list.fold(entries, position, fn(cards, entry) {
    dict.insert(cards, entry.0, entry.1)
  })
}

pub fn insert_one(position: Position, entry: #(Int, Option(PositionCard))) {
  dict.insert(position, entry.0, entry.1)
}

pub fn move_many(position: Position, moves: List(#(Int, Int))) {
  list.fold(moves, position, fn(position, move) { move_one(position, move) })
}

pub fn move_one(position: Position, move: #(Int, Int)) {
  let assert Ok(move_card) = dict.get(position, move.0)

  position
  |> dict.insert(move.1, move_card)
  |> dict.insert(move.0, option.None)
}

pub fn clear(position: Position) {
  dict.map_values(position, fn(_, _) { option.None })
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(position: Position) {
  dict.to_list(position)
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(entry) { entry.1 })
  |> json.array(json.nullable(_, position_card.json))
}

pub fn decoder() {
  position_card.decoder()
  |> decode.optional()
  |> decode.list()
  |> decode.map(fn(positions) {
    positions
    |> list.index_map(fn(position, index) { #(index, position) })
    |> dict.from_list()
  })
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_none(
  position: Position,
  index: Int,
  default_return_value: return_value,
  callback: fn() -> return_value,
) {
  case dict.get(position, index) {
    Ok(option.None) -> callback()
    _ -> default_return_value
  }
}

pub fn use_some(
  position: Position,
  index: Int,
  default_return_value: return_value,
  callback: fn(PositionCard) -> return_value,
) {
  case dict.get(position, index) {
    Ok(option.Some(position_card)) -> callback(position_card)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn is_none(position: Position, index: Int) {
  case dict.get(position, index) {
    Ok(option.None) -> True
    _ -> False
  }
}

pub fn is_some(position: Position, index: Int) {
  case dict.get(position, index) {
    Ok(option.Some(_)) -> True
    _ -> False
  }
}

pub fn is_occupied(position: Position, index: Int, player_index: Int) {
  case dict.get(position, index) {
    Ok(option.Some(position_card)) -> position_card.player_index == player_index
    _ -> False
  }
}
