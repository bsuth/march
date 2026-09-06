import blocks/board
import components/field
import core/lobby.{type Lobby}
import engine/color
import gleam/option
import lib/labels
import lustre/attribute
import lustre/element/html
import phosphor
import routes/lobby/model.{type Model}
import routes/lobby/view/lobby_board_view.{lobby_board_view}
import routes/lobby/view/lobby_members_list_view.{lobby_members_list_view}
import routes/lobby/view/lobby_name_view.{lobby_name_view}
import routes/lobby/view/lobby_variant_view.{lobby_variant_view}
import routes/lobby/view/lobby_visibility_view.{lobby_visibility_view}
import routes/lobby/view/start_game_view.{start_game_view}
import routes/lobby/view/terminate_lobby_view.{terminate_lobby_view}

pub fn view(model: Model) {
  case model.loading_lobby, model.lobby {
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
          attribute.class("border rounded"),
        ],
        [
          html.div([attribute.class("grow flex flex-col gap-4")], [
            html.div([attribute.class("flex items-center justify-between")], [
              lobby_name_view(model, lobby),
              lobby_visibility_view(model, lobby),
              terminate_lobby_view(model, lobby),
            ]),
            html.div([attribute.class("flex gap-4")], [
              lobby_variant_view(model, lobby),
              lobby_board_view(model, lobby),
            ]),
            // TODO: allow clicking here to set player
            field.element([field.label("White")], [
              html.p([], [
                case lobby.white {
                  option.Some(white) -> html.text(labels.user(white))
                  option.None -> html.text("-")
                },
              ]),
            ]),
            board.element([
              attribute.class("w-full h-full"),
              board.board(model.board),
              board.theme(model.app.theme),
              board.color(color.Black),
            ]),
            // TODO: allow clicking here to set player
            field.element(
              [field.label("Black"), attribute.class("text-right")],
              [
                html.p([], [
                  case lobby.black {
                    option.Some(black) -> html.text(labels.user(black))
                    option.None -> html.text("-")
                  },
                ]),
              ],
            ),
          ]),
          start_game_view(model, lobby),
        ],
      ),
      html.div(
        [attribute.class("w-96 flex flex-col gap-4 p-4 border rounded")],
        [
          html.text("Lobby Members"),
          lobby_members_list_view(model, lobby),
        ],
      ),
    ],
  )
}
