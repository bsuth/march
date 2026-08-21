import components/icon_button
import components/text_input
import core/lobby.{type Lobby}
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_name_view(model: Model, lobby: Lobby) {
  let lobby_name = case string.trim(lobby.name) {
    "" -> "Untitled Lobby"
    name -> name
  }

  html.div([attribute.class("w-full min-w-0 flex items-center gap-2")], [
    case model.edit_name {
      option.Some(edit_name) ->
        // TODO: autofocus input on mount
        // TODO: allow pressing Enter to save
        text_input.element([
          attribute.class("grow"),
          text_input.value(edit_name),
          text_input.on_change(message.UserChangedEditName),
        ])

      option.None ->
        html.h2(
          [
            attribute.class("overflow-hidden text-nowrap text-ellipsis"),
            attribute.title(lobby_name),
          ],
          [html.text(lobby_name)],
        )
    },
    case model.app.user.id == lobby.owner.id, model.edit_name {
      False, _ -> element.none()

      True, option.Some(_) ->
        html.div([attribute.class("flex items-center")], [
          icon_button.element(
            [icon_button.on_click(message.UserSavedEditName)],
            [phosphor.check_regular([attribute.class("size-6")])],
          ),
          icon_button.element(
            [icon_button.on_click(message.UserDiscardedEditName)],
            [phosphor.x_regular([attribute.class("size-6")])],
          ),
        ])

      True, option.None ->
        icon_button.element(
          [icon_button.on_click(message.UserEnabledEditName)],
          [phosphor.pencil_regular([attribute.class("size-6")])],
        )
    },
  ])
}
