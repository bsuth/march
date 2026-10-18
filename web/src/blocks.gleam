import blocks/base_icon
import blocks/board
import blocks/card
import blocks/game
import blocks/game_board
import blocks/game_history
import blocks/player_hand

pub fn register() {
  let assert Ok(_) = base_icon.register()
  let assert Ok(_) = board.register()
  let assert Ok(_) = card.register()
  let assert Ok(_) = game.register()
  let assert Ok(_) = game_board.register()
  let assert Ok(_) = game_history.register()
  let assert Ok(_) = player_hand.register()
}
