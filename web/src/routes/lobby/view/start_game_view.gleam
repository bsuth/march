import components/button
import core/lobby.{type Lobby}
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}
import yuzu

pub fn start_game_view(model: Model, lobby: Lobby) {
  use <- yuzu.true(model.app.user.id == lobby.owner.id, element.none())

  button.element(
    [
      attribute.class("m-auto"),
      button.disabled(
        option.is_none(lobby.white) || option.is_none(lobby.black),
      ),
      button.on_click(message.UserStartedGame),
    ],
    [
      html.text("Start Game"),
    ],
  )
}
