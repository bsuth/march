import core/lobby.{type Lobby}
import gleam/option
import lustre/attribute
import lustre/element/html
import phosphor
import routes/lobby/model.{type Model}
import routes/lobby/view/engine_settings_view.{engine_settings_view}
import routes/lobby/view/lobby_name_view.{lobby_name_view}
import routes/lobby/view/lobby_visibility_view.{lobby_visibility_view}
import routes/lobby/view/player_settings_view.{player_settings_view}
import routes/lobby/view/start_game_view.{start_game_view}
import routes/lobby/view/terminate_lobby_view.{terminate_lobby_view}
import routes/lobby/view/user_list_view.{user_list_view}

pub fn view(model: Model) {
  case model.lobby_loading, model.lobby {
    False, option.Some(lobby) -> lobby_view(model, lobby)

    False, option.None ->
      html.div(
        [
          attribute.class("h-full"),
          attribute.class("flex flex-col items-center justify-center gap-4"),
        ],
        [
          phosphor.empty_regular([attribute.class("size-12")]),
          html.text("Lobby Not Found"),
        ],
      )

    True, _ ->
      html.div(
        [
          attribute.class("h-full"),
          attribute.class("flex flex-col items-center justify-center gap-4"),
        ],
        [
          phosphor.circle_notch_regular([
            attribute.class("size-12 animate-spin"),
          ]),
        ],
      )
  }
}

fn lobby_view(model: Model, lobby: Lobby) {
  html.div(
    [
      attribute.class("w-full max-w-6xl h-full m-auto p-8"),
      attribute.class("flex gap-4"),
    ],
    [
      html.div(
        [
          attribute.class("grow min-w-0 p-4"),
          attribute.class("flex flex-col gap-4"),
          attribute.class("border"),
        ],
        [
          html.div([attribute.class("grow flex flex-col gap-4")], [
            html.div([attribute.class("flex items-center justify-between")], [
              lobby_name_view(model, lobby),
              lobby_visibility_view(model, lobby),
              terminate_lobby_view(model, lobby),
            ]),
            engine_settings_view(model, lobby),
            player_settings_view(model, lobby),
            start_game_view(model, lobby),
          ]),
        ],
      ),
      html.div([attribute.class("w-96 flex flex-col gap-4 p-4 border")], [
        html.text("Lobby Members"),
        user_list_view(model, lobby),
      ]),
    ],
  )
}
