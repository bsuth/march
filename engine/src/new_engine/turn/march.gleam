import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/order
import new_engine/board.{type Board}
import new_engine/board/cell.{Cell}
import new_engine/color.{type Color}
import new_engine/trait
import yuzu

pub type March {
  March(source_index: Int, dest_index: Int)
}

pub fn json(march: March) {
  json.object([
    #("source_index", json.int(march.source_index)),
    #("dest_index", json.int(march.dest_index)),
  ])
}

pub fn decoder() {
  use source_index <- decode.field("source_index", decode.int)
  use dest_index <- decode.field("dest_index", decode.int)
  decode.success(March(source_index, dest_index))
}

pub fn do(source_index: Int, dest_index: Int, board: Board, color: Color) {
  use source_cell <- board.use_cell(board, source_index, Error(Nil))
  use source_card <- yuzu.some(source_cell.card, Error(Nil))
  use dest_cell <- board.use_cell(board, dest_index, Error(Nil))

  use <- yuzu.none(dest_cell.card, Error(Nil))
  use <- yuzu.true(source_card.color == color, Error(Nil))
  use <- yuzu.true(
    list_source_indices(board, dest_index, color) |> list.contains(source_index),
    Error(Nil),
  )

  Ok(#(
    March(source_index, dest_index),
    board.update(board, [
      Cell(..source_cell, card: option.None),
      Cell(..dest_cell, card: option.Some(source_card)),
    ]),
  ))
}

pub fn undo(march: March, board: Board) {
  use source_cell <- board.use_cell(board, march.source_index, Error(Nil))
  use dest_cell <- board.use_cell(board, march.dest_index, Error(Nil))

  [
    Cell(..source_cell, card: dest_cell.card),
    Cell(..dest_cell, card: option.None),
  ]
  |> board.update(board, _)
  |> Ok()
}

pub fn list_source_indices(board: Board, dest_index: Int, color: Color) {
  let dest_column = dest_index % board.width
  let dest_row = dest_index / board.width

  let slide_candidates =
    [
      #(board.get_slide_up_cell_index, board.get_slide_down_cell_index),
      #(board.get_slide_down_cell_index, board.get_slide_up_cell_index),
      #(board.get_slide_left_cell_index, board.get_slide_right_cell_index),
      #(board.get_slide_right_cell_index, board.get_slide_left_cell_index),
    ]
    |> list.flat_map(fn(slides) {
      use source_index <- yuzu.some(slides.0(board, dest_index), [])
      use slide_dest_index <- yuzu.some(slides.1(board, source_index), [])
      use <- yuzu.true(slide_dest_index == dest_index, [])
      [#(source_index, trait.Slide)]
    })

  let teleport_candidates =
    [
      #(board.get_all_up_cell_indices, board.get_teleport_down_cell_index),
      #(board.get_all_down_cell_indices, board.get_teleport_up_cell_index),
      #(board.get_all_left_cell_indices, board.get_teleport_right_cell_index),
      #(board.get_all_right_cell_indices, board.get_teleport_left_cell_index),
    ]
    |> list.flat_map(fn(teleports) {
      list.flat_map(teleports.0(board, dest_index), fn(source_index) {
        use slide_dest_index <- yuzu.some(teleports.1(board, source_index), [])
        use <- yuzu.true(slide_dest_index == dest_index, [])
        [#(source_index, trait.Teleport)]
      })
    })

  list.flatten([
    board.get_adjacent_cell_indices(board, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Adjacent) }),
    board.get_adjacent_cell_indices(board, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.AnyMarch) }),
    board.get_diagonal_cell_indices(board, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Diagonal) }),
    board.get_jump_cell_indices(board, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Jump) }),
    board.get_mobius_cell_indices(board, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Mobius) }),
    slide_candidates,
    teleport_candidates,
  ])
  |> list.filter(fn(source_candidate) {
    use <- yuzu.false(source_candidate.1 == trait.AnyMarch, True)

    let source_column = source_candidate.0 % board.width
    let source_row = source_candidate.0 / board.width

    let anti_order = case color {
      color.Black -> order.Gt
      color.White -> order.Lt
    }

    int.compare(source_column, dest_column) != anti_order
    && int.compare(source_row, dest_row) != anti_order
  })
  |> list.flat_map(fn(source_candidate) {
    let #(source_index, source_trait) = source_candidate

    use source_cell <- board.use_cell(board, source_index, [])
    use source_card <- yuzu.some(source_cell.card, [])
    use <- yuzu.true(source_card.color == color, [])

    case list.contains(source_card.traits, source_trait) {
      True -> [source_index]
      False -> []
    }
  })
  |> list.unique()
}
