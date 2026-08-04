import components/field
import components/single_select
import entities/lobby_entity.{type LobbyEntity}
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

// TODO: stop hardcoding all the labels

pub fn lobby_board_view(model: Model, lobby: LobbyEntity) {
  field.element([field.label("Board")], [
    case model.app.user_id == lobby.owner_user_id {
      False ->
        case lobby.board_width, lobby.board_height {
          3, 3 -> html.text("3 x 3")
          _, _ -> html.text("4 x 4")
        }
      True ->
        single_select.element([
          single_select.value(case lobby.board_width, lobby.board_height {
            3, 3 -> "3_by_3"
            _, _ -> "4_by_4"
          }),
          single_select.options([
            #("4_by_4", "4 x 4"),
            #("3_by_3", "3 x 3"),
          ]),
          single_select.on_change(fn(board_string) {
            let #(board_width, board_height) = case board_string {
              "3_by_3" -> #(3, 3)
              _ -> #(4, 4)
            }

            message.UserChangedBoard(board_width, board_height)
          }),
        ])
    },
  ])
}
