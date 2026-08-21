import components/icon_button
import core/lobby.{type Lobby}
import lustre/attribute
import lustre/element
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}
import yuzu

// TODO: add confirmation modal

pub fn terminate_lobby_view(model: Model, lobby: Lobby) {
  use <- yuzu.true(model.app.user.id == lobby.owner.id, element.none())

  icon_button.element(
    [
      icon_button.on_click(message.UserTerminatedLobby),
      attribute.title("Terminate Lobby"),
    ],
    [phosphor.trash_regular([attribute.class("size-8")])],
  )
}
