import blocks/game as game_ui
import lustre/attribute
import routes/playground/message
import routes/playground/model.{type Model}

pub fn view(model: Model) {
  game_ui.element([
    attribute.class("h-full p-8"),
    game_ui.engine_kernel(model.engine.kernel),
    game_ui.on_turn_end(message.CommitTurn),
  ])
}
