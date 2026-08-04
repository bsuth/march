import components/icon_button
import entities/lobby_entity.{type LobbyEntity}
import lustre/attribute
import lustre/element/html
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}

// TODO: add confirmation modal

pub fn lobby_is_public_view(model: Model, lobby: LobbyEntity) {
  html.div([attribute.class("flex items-center gap-2")], [
    icon_button.element(
      [
        icon_button.disabled(model.app.user_id != lobby.owner_user_id),
        icon_button.on_click(message.UserChangedVisibility(!lobby.is_public)),
        case lobby.is_public {
          True -> attribute.title("Public Lobby")
          False -> attribute.title("Private Lobby")
        },
      ],
      [
        case lobby.is_public {
          True -> phosphor.users_three_regular([attribute.class("size-8")])
          False -> phosphor.lock_regular([attribute.class("size-8")])
        },
      ],
    ),
  ])
}
