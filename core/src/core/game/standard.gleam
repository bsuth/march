import core/game/board
import core/game/card.{type Card}
import core/game/classic.{type Classic}
import core/game/color
import core/game/unit.{type Unit}
import core/yuzu
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option}

pub type Standard {
  Standard(classic: Classic)
}

pub type Turn {
  Turn(action: Option(Action), deployment: Option(Card))
}

pub type Action {
  Maneuver(move: #(Int, Int), marches: List(Int))
  JacksCapture(Int, Int)
}

pub fn update_board(game: Standard, updates: List(#(Int, Option(Unit)))) {
  game.classic
  |> classic.update_board(updates)
  |> Standard()
}

pub fn get_active_player(game: Standard) {
  classic.get_active_player(game.classic)
}

pub fn toggle_active_player(game: Standard) {
  game.classic
  |> classic.toggle_active_player()
  |> Standard()
}

pub fn get_cell_moves(game: Standard, source_index: Int) {
  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  use source <- board.use_some(board, source_index, [])
  use <- yuzu.true(source.color == active_player_color, [])

  case source.card.value {
    card.Queen ->
      board.get_adjacent_cell_indices(board, source_index)
      |> list.append(board.get_diagonal_cell_indices(board, source_index))

    _ -> board.get_adjacent_cell_indices(board, source_index)
  }
  |> list.flat_map(fn(dest_index) {
    case dict.get(board.cells, dest_index) {
      Error(_) -> []
      Ok(option.None) -> [#(source_index, dest_index)]
      Ok(option.Some(dest)) -> {
        use <- yuzu.true(unit.can_capture(source, dest), [])
        [#(source_index, dest_index)]
      }
    }
  })
}

pub fn get_cell_marches(game: Standard, dest_index: Int) {
  classic.get_marches(game.classic, dest_index)
  |> list.append(get_cell_queens_marches(game, dest_index))
  |> list.append(get_cell_kings_marches(game, dest_index))
}

pub fn get_cell_queens_marches(game: Standard, dest_index: Int) {
  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  case active_player_color {
    color.Black -> [dest_index - board.size - 1]
    color.White -> [dest_index + board.size + 1]
  }
  |> list.filter(fn(source_index) {
    case dict.get(board.cells, source_index) {
      Error(_) -> False
      Ok(option.None) -> False
      Ok(option.Some(source)) ->
        source.card.value == card.Queen && source.color == active_player_color
    }
  })
}

pub fn get_cell_kings_marches(game: Standard, dest_index: Int) {
  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  case active_player_color {
    color.Black -> [dest_index + board.size, dest_index + 1]
    color.White -> [dest_index - board.size, dest_index - 1]
  }
  |> list.filter(fn(source_index) {
    case dict.get(board.cells, source_index) {
      Error(_) -> False
      Ok(option.None) -> False
      Ok(option.Some(source)) ->
        source.card.value == card.King && source.color == active_player_color
    }
  })
}

pub fn get_cell_jacks_captures(_game: Standard, _source_index: Int) {
  []
}

pub fn use_classic_commit(
  classic_result: Result(Classic, Nil),
  callback: fn() -> Result(Standard, Nil),
) {
  case classic_result {
    Ok(classic) -> Ok(Standard(classic))
    Error(_) -> callback()
  }
}

pub fn commit_turn(game: Standard, turn: Turn) {
  use game <- yuzu.ok(commit_turn_action(game, turn.action), Error(Nil))
  use game <- yuzu.ok(commit_deployment(game, turn.deployment), Error(Nil))

  game
  |> toggle_active_player()
  |> Ok()
}

pub fn commit_turn_action(game: Standard, turn_action: Option(Action)) {
  case turn_action {
    option.Some(Maneuver(move, marches)) -> commit_maneuver(game, move, marches)

    option.Some(JacksCapture(source_index, dest_index)) ->
      commit_jacks_capture(game, source_index, dest_index)

    option.None -> {
      let has_valid_moves =
        list.any(dict.keys(game.classic.board.cells), fn(index) {
          game
          |> get_cell_moves(index)
          |> list.is_empty()
          |> bool.negate()
        })

      let has_valid_jacks_captures =
        list.any(dict.keys(game.classic.board.cells), fn(index) {
          game
          |> get_cell_jacks_captures(index)
          |> list.is_empty()
          |> bool.negate()
        })

      case has_valid_moves || has_valid_jacks_captures {
        True -> Error(Nil)
        False -> Ok(game)
      }
    }
  }
}

pub fn commit_maneuver(game: Standard, move: #(Int, Int), marches: List(Int)) {
  use game <- yuzu.ok(commit_move(game, move.0, move.1), Error(Nil))

  marches
  |> list.reverse()
  |> list.prepend(move.0)
  |> list.window_by_2()
  |> list.try_fold(game, fn(game, march) {
    commit_march(game, march.1, march.0)
  })
}

pub fn commit_move(game: Standard, source_index: Int, dest_index: Int) {
  use <- use_classic_commit(classic.move(game.classic, source_index, dest_index))

  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  use source <- board.use_some(board, source_index, Error(Nil))
  use <- yuzu.true(source.color == active_player_color, Error(Nil))

  use <- yuzu.true(
    source.card.value == card.Queen
      && board.are_diagonal_cell_indices(board, source_index, dest_index),
    Error(Nil),
  )

  [#(source_index, option.None), #(dest_index, option.Some(source))]
  |> update_board(game, _)
  |> Ok()
}

pub fn commit_march(game: Standard, source_index: Int, dest_index: Int) {
  // use <- use_classic_commit(classic.commit_march(
  //   game.classic,
  //   source_index,
  //   dest_index,
  // ))

  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  use source <- board.use_some(board, source_index, Error(Nil))
  use <- yuzu.true(source.color == active_player_color, Error(Nil))

  use <- yuzu.true(
    case source.card.value {
      card.Queen ->
        board.are_diagonal_cell_indices(board, source_index, dest_index)
        && int.absolute_value(source_index - dest_index) == board.size + 1
        && { source.color == color.Black } == { source_index < dest_index }

      card.King ->
        board.are_adjacent_cell_indices(board, source_index, dest_index)

      _ -> False
    },
    Error(Nil),
  )

  [#(source_index, option.None), #(dest_index, option.Some(source))]
  |> update_board(game, _)
  |> Ok()
}

pub fn commit_jacks_capture(
  game: Standard,
  source_index: Int,
  dest_index: Int,
) {
  let board = game.classic.board
  let active_player_color = game.classic.active_player_color

  use source <- board.use_some(board, source_index, Error(Nil))
  use dest <- board.use_some(board, dest_index, Error(Nil))

  use <- yuzu.true(
    source.color == active_player_color
      && source.card.value == card.Jack
      && board.are_adjacent_cell_indices(board, source_index, dest_index)
      && unit.can_capture(source, dest),
    Error(Nil),
  )

  [#(dest_index, option.None)]
  |> update_board(game, _)
  |> Ok()
}

pub fn commit_deployment(game: Standard, _deployment: Option(Card)) {
  Ok(game)
  // case classic.commit_deploy(game.classic, deployment) {
  //   Ok(classic) -> Ok(Standard(classic))
  //   Error(_) -> Error(Nil)
  // }
}
