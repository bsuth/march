import components/button
import components/field
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import routes/lobby/model.{type Model}
import routes/lobby/view/lobby_board_preview_view.{lobby_board_preview_view}
import routes/lobby/view/lobby_board_view.{lobby_board_view}
import routes/lobby/view/lobby_is_public_view.{lobby_is_public_view}
import routes/lobby/view/lobby_members_list_view.{lobby_members_list_view}
import routes/lobby/view/lobby_name_view.{lobby_name_view}
import routes/lobby/view/lobby_variant_view.{lobby_variant_view}
import yuzu

pub fn view(model: Model) {
  use lobby <- yuzu.some(model.lobby, html.text("not found"))

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
              lobby_is_public_view(model, lobby),
            ]),
            html.div([attribute.class("flex gap-4")], [
              lobby_variant_view(model, lobby),
              lobby_board_view(model, lobby),
            ]),
            // TODO: allow clicking here to set player
            field.element([field.label("White")], [
              html.p([], [
                case lobby.white_user_id {
                  option.Some(white_user_id) -> html.text(white_user_id)
                  option.None -> html.text("-")
                },
              ]),
            ]),
            lobby_board_preview_view(lobby.board_width, lobby.board_height),
            field.element(
              [
                field.label("Black"),
                attribute.class("text-right"),
              ],
              [
                // TODO: allow clicking here to set player
                html.p([], [
                  case lobby.black_user_id {
                    option.Some(black_user_id) -> html.text(black_user_id)
                    option.None -> html.text("-")
                  },
                ]),
              ],
            ),
          ]),
          case model.app.user_id == lobby.owner_user_id {
            False -> element.none()
            True ->
              // TODO: actually start the game
              button.element([attribute.class("m-auto")], [
                html.text("Start Game"),
              ])
          },
        ],
      ),
      // TODO: turn unto tabs
      // TODO: add chat tab
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
