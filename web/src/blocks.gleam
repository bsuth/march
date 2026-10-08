import blocks/base_icon
import blocks/board
import blocks/card
import blocks/game

pub fn register() {
  let assert Ok(_) = base_icon.register()
  let assert Ok(_) = board.register()
  let assert Ok(_) = card.register()
  let assert Ok(_) = game.register()
}
