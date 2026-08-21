import components/icon_button
import core/lobby.{type Lobby}
import lustre/attribute
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}

// TODO: add confirmation modal

pub fn lobby_visibility_view(model: Model, lobby: Lobby) {
  icon_button.element(
    [
      icon_button.disabled(model.app.user.id != lobby.owner.id),
      icon_button.on_click(message.UserChangedVisibility(!lobby.visible)),
      case lobby.visible {
        True -> attribute.title("Public Lobby")
        False -> attribute.title("Private Lobby")
      },
    ],
    [
      case lobby.visible {
        True -> phosphor.users_three_regular([attribute.class("size-8")])
        False -> phosphor.lock_regular([attribute.class("size-8")])
      },
    ],
  )
}
