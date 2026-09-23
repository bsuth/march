import components/button
import core/lobby.{type Lobby}
import gleam/list
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
      button.prop_disabled(list.any(lobby.players, option.is_none)),
      button.on_click(message.UserStartedGame),
    ],
    [
      html.text("Start Game"),
    ],
  )
}
