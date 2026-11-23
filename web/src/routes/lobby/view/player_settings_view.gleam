import blocks/board as board_ui
import components/field
import components/single_select
import core/lobby.{type Lobby}
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn player_settings_view(model: Model, lobby: Lobby) {
  let player_options =
    lobby.users
    |> list.map(fn(user) { #(user.id, user.name) })
    |> list.prepend(#("", ""))

  let closure_player_user_view = player_user_view(
    model,
    lobby,
    _,
    player_options,
  )

  html.div([attribute.class("grow flex flex-col gap-4")], [
    html.div([attribute.class("flex justify-between gap-4")], [
      case lobby.engine_settings.doubles {
        True -> closure_player_user_view(2)
        False -> closure_player_user_view(1)
      },
      case lobby.engine_settings.doubles {
        True -> closure_player_user_view(3)
        False -> element.none()
      },
    ]),
    board_ui.element([
      attribute.class("w-full h-full"),
      board_ui.settings(lobby.engine_settings),
    ]),
    html.div([attribute.class("flex flex-row-reverse justify-between gap-4")], [
      closure_player_user_view(0),
      case lobby.engine_settings.doubles {
        True -> closure_player_user_view(1)
        False -> element.none()
      },
    ]),
  ])
}

fn player_user_view(
  model: Model,
  lobby: Lobby,
  player_index: Int,
  player_options: List(#(String, String)),
) {
  let assert Ok(player_user_id) = lobby.get_player_user_id(lobby, player_index)

  field.element([field.label("Player " <> int.to_string(player_index + 1))], [
    case model.app.user.id == lobby.owner_user_id {
      False ->
        html.text(case player_user_id {
          // TODO: fix me
          option.Some(player_user_id) -> player_user_id
          _ -> "-"
        })

      True ->
        single_select.element([
          attribute.class("w-48"),
          single_select.value(option.unwrap(player_user_id, "")),
          single_select.options(player_options),
          single_select.on_change(fn(new_value) {
            message.UserChangedPlayerUserId(player_index, case new_value {
              "" -> option.None
              _ -> option.Some(new_value)
            })
          }),
        ])
    },
  ])
}
