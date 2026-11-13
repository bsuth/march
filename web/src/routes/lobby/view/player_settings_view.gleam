import blocks/board as board_ui
import components/field
import components/single_select
import core/lobby.{type Lobby}
import gleam/list
import gleam/option
import lib/player_color.{type PlayerColor}
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

  let closure_player_color_view = player_color_view(
    model,
    lobby,
    _,
    player_options,
  )

  html.div([attribute.class("grow flex flex-col gap-4")], [
    html.div([attribute.class("flex justify-between gap-4")], [
      closure_player_color_view(player_color.White),
      case lobby.engine_settings.doubles {
        True -> closure_player_color_view(player_color.DarkRed)
        False -> element.none()
      },
    ]),
    board_ui.element([
      attribute.class("w-full h-full"),
      board_ui.prop_settings(lobby.engine_settings),
      board_ui.prop_theme(model.app.theme),
    ]),
    html.div([attribute.class("flex flex-row-reverse justify-between gap-4")], [
      closure_player_color_view(player_color.Black),
      case lobby.engine_settings.doubles {
        True -> closure_player_color_view(player_color.LightRed)
        False -> element.none()
      },
    ]),
  ])
}

fn player_color_view(
  model: Model,
  lobby: Lobby,
  player_color: PlayerColor,
  player_options: List(#(String, String)),
) {
  let player_index =
    player_color.to_player_index(player_color, lobby.engine_settings.doubles)

  let assert Ok(player_user_id) = lobby.get_player_user_id(lobby, player_index)

  field.element([field.prop_label(player_color.label(player_color))], [
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
          single_select.prop_value(option.unwrap(player_user_id, "")),
          single_select.prop_options(player_options),
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
