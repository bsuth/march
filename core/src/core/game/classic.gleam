import core/game/board.{type Board}
import core/game/card.{type Card}
import core/game/color.{type Color}
import core/game/player.{type Player}
import core/game/unit.{type Unit, Unit}
import core/yuzu
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}

pub type Classic {
  Classic(
    board: Board,
    black: Player,
    white: Player,
    active_player_color: Color,
    history: List(Action),
  )
}

pub type Action {
  Move(Int, Int, Option(Unit))
  March(Int, Int)
  Deploy(Card)
  Pass
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(game: Classic) {
  json.object([
    #("board", board.json(game.board)),
    #("black", player.json(game.black)),
    #("white", player.json(game.white)),
    #("active_player_color", color.json(game.active_player_color)),
    #("history", json.array(game.history, action_json)),
  ])
}

pub fn action_json(action: Action) {
  case action {
    Move(source_index, dest_index, capture) ->
      json.object([
        #("action", json.string("move")),
        #("source_index", json.int(source_index)),
        #("dest_index", json.int(dest_index)),
        #("capture", json.nullable(capture, unit.json)),
      ])

    March(source_index, dest_index) ->
      json.object([
        #("action", json.string("march")),
        #("source_index", json.int(source_index)),
        #("dest_index", json.int(dest_index)),
      ])

    Deploy(card) ->
      json.object([
        #("action", json.string("deploy")),
        #("card", card.json(card)),
      ])

    Pass ->
      json.object([
        #("action", json.string("pass")),
      ])
  }
}

pub fn decoder() {
  use board <- decode.field("board", board.decoder())
  use black <- decode.field("black", player.decoder())
  use white <- decode.field("white", player.decoder())
  use history <- decode.field("history", decode.list(action_decoder()))

  use active_player_color <- decode.field(
    "active_player_color",
    color.decoder(),
  )

  decode.success(Classic(board:, black:, white:, active_player_color:, history:))
}

pub fn action_decoder() {
  use action <- decode.field("action", decode.string)

  case action {
    "move" -> {
      use source_index <- decode.field("source_index", decode.int)
      use dest_index <- decode.field("dest_index", decode.int)
      use capture <- decode.field("capture", decode.optional(unit.decoder()))
      decode.success(Move(source_index, dest_index, capture))
    }

    "march" -> {
      use source_index <- decode.field("source_index", decode.int)
      use dest_index <- decode.field("dest_index", decode.int)
      decode.success(March(source_index, dest_index))
    }

    "deploy" -> {
      use card <- decode.field("card", card.decoder())
      decode.success(Deploy(card))
    }

    "pass" -> decode.success(Pass)
    _ -> decode.failure(Pass, "Action")
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

pub fn update_player(game: Classic, player: Player) {
  case player.color {
    color.Black -> Classic(..game, black: player)
    color.White -> Classic(..game, white: player)
  }
}

pub fn update_board(game: Classic, updates: List(#(Int, Option(Unit)))) {
  game.board
  |> board.update(updates)
  |> fn(board) { Classic(..game, board:) }
}

pub fn toggle_active_player(game: Classic) {
  Classic(..game, active_player_color: case game.active_player_color {
    color.Black -> color.White
    color.White -> color.Black
  })
}

// -----------------------------------------------------------------------------
// Queries
// -----------------------------------------------------------------------------

// TODO: should the base index be a property of the player?
pub fn get_base_index(board: Board, color: Color) {
  case color {
    color.Black -> 0
    color.White -> board.size * board.size - 1
  }
}

pub fn get_active_player(game: Classic) {
  case game.active_player_color {
    color.Black -> game.black
    color.White -> game.white
  }
}

pub fn get_moves(game: Classic) {
  dict.map_values(game.board.cells, fn(source_index, source_cell) {
    use source <- yuzu.some(source_cell, [])
    use <- yuzu.true(source.color == game.active_player_color, [])

    game.board
    |> board.get_adjacent_cell_indices(source_index)
    |> list.flat_map(fn(dest_index) {
      case dict.get(game.board.cells, dest_index) {
        Error(_) -> []
        Ok(option.None) -> [#(source_index, dest_index, option.None)]
        Ok(option.Some(dest)) -> {
          use <- yuzu.true(unit.can_capture(source, dest), [])
          [#(source_index, dest_index, option.Some(dest))]
        }
      }
    })
  })
}

pub fn get_marches(game: Classic, dest_index: Int) {
  game.board
  |> board.get_adjacent_cell_indices(dest_index)
  |> list.filter(case game.active_player_color {
    color.Black -> fn(march_index) { march_index < dest_index }
    color.White -> fn(march_index) { march_index > dest_index }
  })
  |> list.filter(fn(source_index) {
    use source <- board.use_some(game.board, source_index, False)
    use <- yuzu.true(source.color == game.active_player_color, False)

    case game.history {
      [Move(_, prev_dest_index, _), ..] -> source_index != prev_dest_index
      _ -> True
    }
  })
}

// -----------------------------------------------------------------------------
// Actions
// -----------------------------------------------------------------------------

pub fn move(game: Classic, source_index: Int, dest_index: Int) {
  use <- yuzu.true(
    case game.history {
      [] -> True
      [prev_action, ..] -> prev_action == Pass
    },
    Error(Nil),
  )

  use source <- board.use_some(game.board, source_index, Error(Nil))

  use <- yuzu.true(
    source.color == game.active_player_color
      && board.are_adjacent_cell_indices(game.board, source_index, dest_index),
    Error(Nil),
  )

  use capture <- yuzu.ok(
    case dict.get(game.board.cells, dest_index) {
      Error(_) -> Error(Nil)
      Ok(option.None) -> Ok(option.None)
      Ok(option.Some(dest)) -> {
        use <- yuzu.true(unit.can_capture(source, dest), Error(Nil))
        Ok(option.Some(dest))
      }
    },
    Error(Nil),
  )

  [#(source_index, option.None), #(dest_index, option.Some(source))]
  |> update_board(game, _)
  |> prepend_history(Move(source_index, dest_index, capture))
  |> Ok()
}

pub fn march(game: Classic, source_index: Int) {
  use dest_index <- yuzu.ok(
    case game.history {
      [Move(source_index, _, _), ..] -> Ok(source_index)
      [March(dest_index, _), ..] -> Ok(dest_index)
      _ -> Error(Nil)
    },
    Error(Nil),
  )

  use source <- board.use_some(game.board, source_index, Error(Nil))

  use <- yuzu.true(
    source.color == game.active_player_color
      && board.are_adjacent_cell_indices(game.board, source_index, dest_index)
      && { source.color == color.Black } == { source_index < dest_index },
    Error(Nil),
  )

  [#(source_index, option.None), #(dest_index, option.Some(source))]
  |> update_board(game, _)
  |> prepend_history(March(source_index, dest_index))
  |> Ok()
}

pub fn deploy(game: Classic, card: Card) {
  let active_player = get_active_player(game)
  let active_player_base_index = get_base_index(game.board, active_player.color)

  case dict.get(game.board.cells, active_player_base_index) {
    Error(_) -> Error(Nil)
    Ok(option.Some(_)) -> Error(Nil)
    Ok(option.None) -> {
      use active_player <- yuzu.ok(
        player.deploy(active_player, card),
        Error(Nil),
      )

      let unit = Unit(card, active_player.color)
      let game = update_player(game, active_player)

      [#(active_player_base_index, option.Some(unit))]
      |> update_board(game, _)
      |> prepend_history(Deploy(card))
      |> Ok()
    }
  }
}

pub fn pass(game: Classic) {
  let active_player = get_active_player(game)
  let active_player_base_index = get_base_index(game.board, active_player.color)

  use <- yuzu.true(
    !board.is_none(game.board, active_player_base_index)
      || player.has_empty_hand(active_player),
    Error(Nil),
  )

  use <- yuzu.true(
    case game.history {
      [] -> False

      [Pass, ..] ->
        game
        |> get_moves()
        |> dict.values()
        |> list.flatten()
        |> list.is_empty()

      _ -> True
    },
    Error(Nil),
  )

  use active_player <- yuzu.ok(player.draw_until(active_player, 4), Error(Nil))

  update_player(game, active_player)
  |> toggle_active_player()
  |> prepend_history(Pass)
  |> Ok()
}

// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------

pub fn prepend_history(game: Classic, action: Action) {
  Classic(..game, history: list.prepend(game.history, action))
}

pub fn undo_history(game: Classic) {
  use head, tail <- yuzu.non_empty_list(game.history, Error(Nil))
  let game = Classic(..game, history: tail)

  case head {
    Move(source_index, dest_index, option.Some(capture)) -> {
      use cell <- yuzu.ok(dict.get(game.board.cells, dest_index), Error(Nil))
      [#(source_index, cell), #(dest_index, option.Some(capture))]
      |> update_board(game, _)
      |> Ok()
    }

    Move(source_index, dest_index, option.None) -> {
      use cell <- yuzu.ok(dict.get(game.board.cells, dest_index), Error(Nil))
      [#(source_index, cell), #(dest_index, option.None)]
      |> update_board(game, _)
      |> Ok()
    }

    March(source_index, dest_index) -> {
      use cell <- yuzu.ok(dict.get(game.board.cells, dest_index), Error(Nil))
      [#(source_index, cell), #(dest_index, option.None)]
      |> update_board(game, _)
      |> Ok()
    }

    Deploy(card) -> {
      let active_player = get_active_player(game)
      let active_player_base_index =
        get_base_index(game.board, active_player.color)

      use active_player <- yuzu.ok(
        case active_player {
          player.Managed(color, hand, deck) ->
            Ok(player.Managed(color:, hand: list.prepend(hand, card), deck:))
          player.Controlled(color, hand, deck) ->
            Ok(player.Controlled(color:, hand: list.prepend(hand, card), deck:))
          player.Observed(_, _, _) -> Error(Nil)
        },
        Error(Nil),
      )

      update_player(game, active_player)
      |> update_board([#(active_player_base_index, option.None)])
      |> Ok()
    }

    _ -> Error(Nil)
  }
}
