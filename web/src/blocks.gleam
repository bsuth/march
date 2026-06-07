import blocks/game
import blocks/theme_toggle

pub fn register() {
  let assert Ok(_) = game.register()
  let assert Ok(_) = theme_toggle.register()
}
