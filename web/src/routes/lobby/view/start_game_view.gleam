import components/button
import core/lobby.{type Lobby}
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import routes/lobby/message
import routes/lobby/model.{type Model}
import yuzu

pub fn start_game_view(model: Model, lobby: Lobby) {
  use <- yuzu.true(model.app.user.id == lobby.owner_user_id, element.none())

  button.element(
    [
      attribute.class("m-auto"),
      button.disabled(list.any(lobby.player_user_ids, option.is_none)),
      event.on_click(message.UserStartedGame),
    ],
    [
      html.text("Start Game"),
    ],
  )
}
