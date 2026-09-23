import components/field
import components/single_select
import core/lobby.{type Lobby}
import engine/board
import gleam/int
import gleam/list
import gleam/string
import lib/labels
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_board_view(model: Model, lobby: Lobby) {
  let width = lobby.engine_settings.board.width
  let height = lobby.engine_settings.board.height

  field.element([field.prop_label("Board")], [
    case model.app.user.id == lobby.owner.id {
      False -> html.text(labels.board(width, height))
      True ->
        single_select.element([
          single_select.prop_value(
            int.to_string(width) <> "x" <> int.to_string(height),
          ),
          single_select.prop_options([
            #("4x4", labels.board(4, 4)),
            #("3x3", labels.board(3, 3)),
          ]),
          single_select.on_change(fn(board_string) {
            case string.split(board_string, "x") |> list.map(int.parse) {
              [Ok(new_width), Ok(new_height)] ->
                message.UserChangedBoard(board.normal(new_width, new_height))
              _ -> message.UserChangedBoard(board.normal(width, height))
            }
          }),
        ])
    },
  ])
}
