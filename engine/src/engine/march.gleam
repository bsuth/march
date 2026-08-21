import engine/board.{type Board}
import engine/board/cell.{Cell}
import engine/color.{type Color}
import engine/trait.{type Trait}
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import yuzu

pub fn commit(source_index: Int, dest_index: Int, board: Board, color: Color) {
  use source_cell <- board.use_cell(board, source_index, Error(Nil))
  use source_card <- yuzu.some(source_cell.card, Error(Nil))
  use dest_cell <- board.use_cell(board, dest_index, Error(Nil))

  use <- yuzu.none(dest_cell.card, Error(Nil))
  use <- yuzu.true(source_card.color == color, Error(Nil))

  // TODO: validate by generating marches from source index? should be more performant.
  use <- yuzu.true(
    list_source_indices(board, dest_index, color) |> list.contains(source_index),
    Error(Nil),
  )

  [
    Cell(..source_cell, card: option.None),
    Cell(..dest_cell, card: option.Some(source_card)),
  ]
  |> board.update(board, _)
  |> Ok()
}

pub fn list_source_indices(board: Board, dest_index: Int, color: Color) {
  [
    list_adjacent_source_indices(board, dest_index, color),
    list_diagonal_source_indices(board, dest_index, color),
    list_jump_source_indices(board, dest_index, color),
    list_mobius_source_indices(board, dest_index, color),
    list_slide_source_indices(board, dest_index, color),
    list_teleport_source_indices(board, dest_index, color),
  ]
  |> list.flatten()
  |> list.unique()
}

fn list_adjacent_source_indices(board: Board, dest_index: Int, color: Color) {
  list.filter(
    board.get_adjacent_cell_indices(board, dest_index),
    is_valid_march_source_index(_, dest_index, board, trait.Adjacent, color),
  )
}

fn list_diagonal_source_indices(board: Board, dest_index: Int, color: Color) {
  list.filter(
    board.get_diagonal_cell_indices(board, dest_index),
    is_valid_march_source_index(_, dest_index, board, trait.Diagonal, color),
  )
}

fn list_jump_source_indices(board: Board, dest_index: Int, color: Color) {
  list.filter(
    board.get_jump_cell_indices(board, dest_index),
    is_valid_march_source_index(_, dest_index, board, trait.Jump, color),
  )
}

fn list_mobius_source_indices(board: Board, dest_index: Int, color: Color) {
  list.filter(
    board.get_mobius_cell_indices(board, dest_index),
    is_valid_march_source_index(_, dest_index, board, trait.Mobius, color),
  )
}

fn list_slide_source_indices(board: Board, dest_index: Int, color: Color) {
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
    [source_index]
  })
  |> list.filter(is_valid_march_source_index(
    _,
    dest_index,
    board,
    trait.Slide,
    color,
  ))
}

fn list_teleport_source_indices(board: Board, dest_index: Int, color: Color) {
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
      [source_index]
    })
  })
  |> list.filter(is_valid_march_source_index(
    _,
    dest_index,
    board,
    trait.Teleport,
    color,
  ))
}

fn is_valid_march_source_index(
  source_index: Int,
  dest_index: Int,
  board: Board,
  trait: Trait,
  color: Color,
) {
  use source_cell <- board.use_cell(board, source_index, False)
  use source_card <- yuzu.some(source_cell.card, False)
  use <- yuzu.true(source_card.color == color, False)
  use <- yuzu.true(list.contains(source_card.traits, trait), False)
  use <- yuzu.false(list.contains(source_card.traits, trait.AnyMarch), True)

  let source_column = source_index % board.width
  let source_row = source_index / board.width
  let dest_column = dest_index % board.width
  let dest_row = dest_index / board.width

  let anti_order = case color {
    color.Black -> order.Gt
    color.White -> order.Lt
  }

  int.compare(source_column, dest_column) != anti_order
  && int.compare(source_row, dest_row) != anti_order
}
