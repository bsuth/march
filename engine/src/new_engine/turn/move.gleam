import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import new_engine/board.{type Board}
import new_engine/board/cell.{type Cell, Cell}
import new_engine/card.{type Card}
import new_engine/color.{type Color}
import new_engine/trait
import yuzu

pub type Move {
  Move(source_index: Int, dest_index: Int, capture: Option(Card))
}

pub fn json(move: Move) {
  json.object([
    #("source_index", json.int(move.source_index)),
    #("dest_index", json.int(move.dest_index)),
    #("capture", json.nullable(move.capture, card.json)),
  ])
}

pub fn decoder() {
  use source_index <- decode.field("source_index", decode.int)
  use dest_index <- decode.field("dest_index", decode.int)
  use capture <- decode.field("capture", decode.optional(card.decoder()))
  decode.success(Move(source_index, dest_index, capture))
}

pub fn do(source_index: Int, dest_index: Int, board: Board, color: Color) {
  use source_cell <- board.use_cell(board, source_index, Error(Nil))
  use source_card <- yuzu.some(source_cell.card, Error(Nil))
  use dest_cell <- board.use_cell(board, dest_index, Error(Nil))

  use <- yuzu.true(source_card.color == color, Error(Nil))
  use <- yuzu.true(
    list_dest_indices(board, source_cell) |> list.contains(dest_index),
    Error(Nil),
  )

  Ok(#(
    Move(source_index, dest_index, dest_cell.card),
    board.update(board, [
      Cell(..source_cell, card: option.None),
      Cell(..dest_cell, card: option.Some(source_card)),
    ]),
  ))
}

pub fn undo(move: Move, board: Board) {
  use source_cell <- board.use_cell(board, move.source_index, Error(Nil))
  use dest_cell <- board.use_cell(board, move.dest_index, Error(Nil))

  [
    Cell(..source_cell, card: dest_cell.card),
    Cell(..dest_cell, card: move.capture),
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
        |> list.map(fn(dest_index) { #(dest_index, True) })

      trait.Diagonal ->
        board.get_diagonal_cell_indices(board, source_cell.index)
        |> list.map(fn(dest_index) { #(dest_index, True) })

      trait.Jump ->
        board.get_jump_cell_indices(board, source_cell.index)
        |> list.map(fn(dest_index) { #(dest_index, False) })

      trait.Mobius ->
        board.get_mobius_cell_indices(board, source_cell.index)
        |> list.map(fn(dest_index) { #(dest_index, False) })

      trait.Slide ->
        board.get_slide_cell_indices(board, source_cell.index)
        |> list.map(fn(dest_index) { #(dest_index, True) })

      trait.Teleport ->
        board.get_teleport_cell_indices(board, source_cell.index)
        |> list.map(fn(dest_index) { #(dest_index, False) })

      _ -> []
    }
  })
  |> list.flat_map(fn(dest) {
    let #(dest_index, allow_capture) = dest

    case dict.get(board.cells, dest_index) {
      Error(_) -> []
      Ok(Cell(_, _, option.None)) -> [dest_index]
      Ok(Cell(_, _, option.Some(dest_card))) -> {
        use <- yuzu.true(allow_capture, [])
        use <- yuzu.true(card.can_capture(source_card, dest_card), [])
        [dest_index]
      }
    }
  })
  |> list.unique()
}
