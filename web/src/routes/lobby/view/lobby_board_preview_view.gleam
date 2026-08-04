import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import phosphor

pub fn lobby_board_preview_view(width: Int, height: Int) {
  html.div(
    [attribute.class("flex-1 flex flex-col")],
    int.range(0, height, [], fn(rows, row_index) {
      let columns =
        int.range(0, width, [], fn(columns, column_index) {
          lobby_board_cell_preview_view(width, height, row_index, column_index)
          |> list.prepend(columns, _)
        })

      let row =
        html.div([attribute.class("flex-1 flex relative")], [
          html.div(
            [attribute.class("absolute inset-0 flex justify-center")],
            columns,
          ),
        ])

      list.prepend(rows, row)
    }),
  )
}

fn lobby_board_cell_preview_view(
  width: Int,
  height: Int,
  row: Int,
  column: Int,
) {
  html.div(
    [
      attribute.class("aspect-square"),
      attribute.class("flex justify-center items-center"),
      attribute.class("border-t border-r first:border-l"),
      case row == 0 {
        True -> attribute.class("border-b")
        False -> attribute.none()
      },
    ],
    [
      // TODO: change between fill and regular based on theme
      case row, column {
        0, 0 -> phosphor.castle_turret_fill([attribute.class("size-1/2")])

        _, _ if row == height - 1 && column == width - 1 ->
          phosphor.castle_turret_regular([attribute.class("size-1/2")])

        _, _ -> element.none()
      },
    ],
  )
}
