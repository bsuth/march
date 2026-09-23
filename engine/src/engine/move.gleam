import engine/board.{type Board}
import engine/card
import engine/player.{type Player}
import engine/settings.{type Settings}
import engine/trait
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import yuzu

pub fn list_raw_source_indices(
  dest_index: Int,
  board: Board,
  settings: Settings,
) {
  list_trait_source_indices(dest_index, board, settings)
  |> list.map(fn(entry) { entry.0 })
  |> list.unique()
}

pub fn list_valid_source_indices(
  dest_index: Int,
  player: Player,
  board: Board,
  settings: Settings,
) {
  use dest <- yuzu.ok(dict.get(board, dest_index), [])

  list_trait_source_indices(dest_index, board, settings)
  |> list.filter(fn(entry) {
    use source_card <- board.use_some(board, entry.0, False)
    use <- yuzu.true_(source_card.player_index == player.index)

    case dest {
      option.Some(dest_card) -> card.can_capture(source_card, dest_card)
      option.None -> True
    }
  })
  |> list.map(fn(entry) { entry.0 })
  |> list.unique()
}

fn list_trait_source_indices(
  dest_index: Int,
  board: Board,
  settings: Settings,
) {
  [
    board.get_adjacent_indices(settings, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Adjacent) }),
    board.get_diagonal_indices(settings, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Diagonal) }),
    board.get_jump_indices(settings, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Jump) }),
    board.get_mobius_indices(settings, dest_index)
      |> list.map(fn(source_index) { #(source_index, trait.Mobius) }),
  ]
  |> list.flatten()
  |> list.filter(fn(entry) {
    use source_card <- board.use_some(board, entry.0, False)

    settings.traits
    |> dict.get(source_card.face)
    |> result.unwrap([])
    |> list.contains(entry.1)
  })
}

pub fn list_raw_dest_indices(
  source_index: Int,
  board: Board,
  settings: Settings,
) {
  list_trait_dest_indices(source_index, board, settings)
  |> list.map(fn(entry) { entry.0 })
  |> list.unique()
}

pub fn list_valid_dest_indices(
  source_index: Int,
  player: Player,
  board: Board,
  settings: Settings,
) {
  use source_card <- board.use_some(board, source_index, [])
  use <- yuzu.true(source_card.player_index == player.index, [])

  list_trait_dest_indices(source_index, board, settings)
  |> list.filter(fn(entry) {
    case entry.1 {
      trait.Adjacent | trait.Diagonal -> {
        use dest_card <- board.use_some(board, entry.0, False)
        card.can_capture(source_card, dest_card)
      }

      trait.Jump | trait.Mobius -> board.is_none(board, entry.0)

      trait.AnyMarch -> False
    }
  })
  |> list.map(fn(entry) { entry.0 })
  |> list.unique()
}

fn list_trait_dest_indices(
  source_index: Int,
  board: Board,
  settings: Settings,
) {
  use source_card <- board.use_some(board, source_index, [])

  dict.get(settings.traits, source_card.face)
  |> result.unwrap([])
  |> list.flat_map(fn(trait) {
    case trait {
      trait.Adjacent ->
        board.get_adjacent_indices(settings, source_index)
        |> list.map(fn(dest_index) { #(dest_index, trait.Adjacent) })

      trait.Diagonal ->
        board.get_diagonal_indices(settings, source_index)
        |> list.map(fn(dest_index) { #(dest_index, trait.Diagonal) })

      trait.Jump ->
        board.get_jump_indices(settings, source_index)
        |> list.map(fn(dest_index) { #(dest_index, trait.Jump) })

      trait.Mobius ->
        board.get_mobius_indices(settings, source_index)
        |> list.map(fn(dest_index) { #(dest_index, trait.Mobius) })

      _ -> []
    }
  })
}

pub fn is_march_index(
  source_index: Int,
  dest_index: Int,
  player: Player,
  board: Board,
  settings: Settings,
) {
  use source_card <- board.use_some(board, source_index, False)

  let traits =
    settings.traits
    |> dict.get(source_card.face)
    |> result.unwrap([])

  use <- yuzu.false_(list.contains(traits, trait.AnyMarch))

  let source_column = source_index % settings.width
  let source_row = source_index / settings.width
  let dest_column = dest_index % settings.width
  let dest_row = dest_index / settings.width

  case player.index, settings.doubles {
    0, False -> source_column <= dest_column && source_row <= dest_row
    1, False -> source_column >= dest_column && source_row >= dest_row

    0, True -> source_column <= dest_column && source_row <= dest_row
    1, True -> source_column >= dest_column && source_row <= dest_row
    2, True -> source_column >= dest_column && source_row >= dest_row
    3, True -> source_column <= dest_column && source_row >= dest_row

    _, _ -> False
  }
}
