import components/field
import components/single_select
import core/lobby.{type Lobby}
import engine/board
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element/html
import routes/lobby/message
import routes/lobby/model.{type Model}

pub fn lobby_board_view(model: Model, lobby: Lobby) {
  let width = lobby.engine_settings.board.width
  let height = lobby.engine_settings.board.height

  field.element([field.prop_label("Board")], [
    case model.app.user.id == lobby.owner.id {
      False ->
        html.div([attribute.class("flex items-center gap-2")], [
          html.p([], [html.text(int.to_string(width))]),
          html.p([], [html.text("x")]),
          html.p([], [html.text(int.to_string(height))]),
        ])

      True ->
        html.div([attribute.class("flex items-center gap-2")], [
          single_select.element([
            single_select.prop_value(int.to_string(width)),
            single_select.prop_options(
              int.range(9, 0, [], fn(options, width) {
                let width_string = int.to_string(width)
                list.prepend(options, #(width_string, width_string))
              }),
            ),
            single_select.on_change(fn(width_string) {
              case int.parse(width_string) {
                Ok(width) ->
                  message.UserChangedBoard(board.normal(width, height))
                _ -> message.UserChangedBoard(board.normal(width, height))
              }
            }),
          ]),
          html.text("x"),
          single_select.element([
            single_select.prop_value(int.to_string(height)),
            single_select.prop_options(
              int.range(9, 0, [], fn(options, height) {
                let height_string = int.to_string(height)
                list.prepend(options, #(height_string, height_string))
              }),
            ),
            single_select.on_change(fn(height_string) {
              case int.parse(height_string) {
                Ok(height) ->
                  message.UserChangedBoard(board.normal(width, height))
                _ -> message.UserChangedBoard(board.normal(width, height))
              }
            }),
          ]),
        ])
    },
  ])
}
