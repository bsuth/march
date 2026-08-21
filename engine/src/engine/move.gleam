import engine/board.{type Board}
import engine/board/cell.{type Cell, Cell}
import engine/card.{type Card}
import engine/color.{type Color}
import engine/trait
import gleam/dict
import gleam/list
import gleam/option
import yuzu

pub fn commit(source_index: Int, dest_index: Int, board: Board, color: Color) {
  use source_cell <- board.use_cell(board, source_index, Error(Nil))
  use source_card <- yuzu.some(source_cell.card, Error(Nil))
  use dest_cell <- board.use_cell(board, dest_index, Error(Nil))

  use <- yuzu.true(source_card.color == color, Error(Nil))
  use <- yuzu.true(
    list_dest_indices(board, source_cell) |> list.contains(dest_index),
    Error(Nil),
  )

  [
    Cell(..source_cell, card: option.None),
    Cell(..dest_cell, card: option.Some(source_card)),
  ]
  |> board.update(board, _)
  |> Ok()
}

pub fn list_dest_indices(board: Board, source_cell: Cell) {
  use source_card <- yuzu.some(source_cell.card, [])

  source_card.traits
  |> list.flat_map(fn(trait) {
    case trait {
      trait.Adjacent ->
        board.get_adjacent_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, True))

      trait.Diagonal ->
        board.get_diagonal_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, True))

      trait.Jump ->
        board.get_jump_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, False))

      trait.Mobius ->
        board.get_mobius_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, False))

      trait.Slide ->
        board.get_slide_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, True))

      trait.Teleport ->
        board.get_teleport_cell_indices(board, source_cell.index)
        |> list.filter(is_valid_dest_index(_, board, source_card, False))

      _ -> []
    }
  })
  |> list.unique()
}

fn is_valid_dest_index(
  dest_index: Int,
  board: Board,
  source_card: Card,
  allow_capture: Bool,
) {
  case dict.get(board.cells, dest_index) {
    Error(_) -> False
    Ok(Cell(_, _, option.None)) -> True
    Ok(Cell(_, _, option.Some(dest_card))) ->
      allow_capture && card.can_capture(source_card, dest_card)
  }
}
