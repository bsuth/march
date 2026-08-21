import components/field
import components/single_select
import core/lobby.{type Lobby}
import gleam/int
import gleam/list
import gleam/string
import lib/labels
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_board_view(model: Model, lobby: Lobby) {
  field.element([field.label("Board")], [
    case model.app.user.id == lobby.owner.id {
      False -> html.text(labels.board(lobby.board_width, lobby.board_height))
      True ->
        single_select.element([
          single_select.value(
            int.to_string(lobby.board_width)
            <> "x"
            <> int.to_string(lobby.board_height),
          ),
          single_select.options([
            #("4x4", labels.board(4, 4)),
            #("3x3", labels.board(3, 3)),
          ]),
          single_select.on_change(fn(board_string) {
            case string.split(board_string, "x") |> list.map(int.parse) {
              [Ok(board_width), Ok(board_height)] ->
                message.UserChangedBoard(board_width, board_height)
              _ -> message.UserChangedBoard(4, 4)
            }
          }),
        ])
    },
  ])
}
