import gleam/dict
import lib/game/board.{type Board}
import lib/game/card
import lib/game/player.{type Player}

pub type Game {
  Game(a: Player, b: Player, board: Board, turn: Bool)
}

pub type Action {
  March(List(#(Int, Int)))
  Assassinate(Int, Int)
  Stealth(Int)
}

pub fn new() {
  Game(a: player.new(), b: player.new(), board: board.new(4), turn: True)
}

pub fn is_valid_action(game: Game, action: Action) {
  case action {
    March(march) -> is_valid_march(game, march)
    Assassinate(source, dest) -> is_valid_assassinate(game, source, dest)
    Stealth(source) -> is_valid_stealth(game, source)
  }
}

fn is_valid_march(_game: Game, _march: List(#(Int, Int))) {
  // 1. Check length is at least 1
  // 2. Check if first move is valid move or capture
  // 3. Check if rest are valid marches
  // 4. Check if last card must be from hand (+ is in hand)
  True
}

fn is_valid_assassinate(game: Game, source_index: Int, dest_index: Int) {
  let active_player = case game.turn {
    True -> game.a
    False -> game.b
  }

  case
    dict.get(game.board.cells, source_index),
    dict.get(game.board.cells, source_index)
  {
    Ok(board.Occupied(source_player, source_card)),
      Ok(board.Occupied(dest_player, dest_card))
    -> {
      source_player == active_player
      && source_card.value == card.Jack
      && dest_player != active_player
      && card.can_capture(source_card, dest_card)
      && board.are_adjacent_cell_indices(game.board, source_index, dest_index)
    }

    _, _ -> False
  }
}

fn is_valid_stealth(_game: Game, _source: Int) {
  // 1. Check if source is active player's Queen
  // 2. Check if card is already stealthed
  // 3. If stealthed, check if cell is empty or capturable
  True
}
