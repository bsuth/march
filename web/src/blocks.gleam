import blocks/board
import blocks/card
import blocks/game
import blocks/old_game

pub fn register() {
  let assert Ok(_) = board.register()
  let assert Ok(_) = card.register()
  let assert Ok(_) = game.register()
  let assert Ok(_) = old_game.register()
}
