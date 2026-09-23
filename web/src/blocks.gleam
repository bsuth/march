import blocks/board
import blocks/card
import blocks/game

pub fn register() {
  let assert Ok(_) = board.register()
  let assert Ok(_) = card.register()
  let assert Ok(_) = game.register()
}
