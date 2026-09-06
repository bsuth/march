import engine/board.{type Board}
import engine/board/cell.{Cell}
import engine/board/tile
import engine/card.{type Card}
import engine/color.{type Color}
import engine/deploy
import engine/march
import engine/move
import engine/player.{type Player}
import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import yuzu

pub type Engine {
  Engine(
    active_player_color: Color,
    black: Player,
    board: Board,
    history: List(HistoryItem),
    white: Player,
  )
}

pub type Turn {
  Turn(
    color: Color,
    move: #(Int, Int),
    marches: List(Int),
    deploy: Option(Card),
  )
}

pub type ActiveTurn {
  ActiveStartTurn
  ActiveMarchTurn(move: #(Int, Int), marches: List(Int))
  ActiveDeployTurn(move: #(Int, Int), marches: List(Int), deploy: Card)
  ActiveDeployOnlyTurn(deploy: Card)
}

pub type HistoryItem {
  HistoryDraw(Card)
  HistoryPass
  HistoryTurn(
    color: Color,
    move: #(Int, Int, Option(Card)),
    marches: List(#(Int, Int)),
    deploy: Option(Card),
  )
}

pub fn json(engine: Engine) {
  json.object([
    #("board", board.json(engine.board)),
    #("black", player.json(engine.black)),
    #("white", player.json(engine.white)),
    #("active_player_color", color.json(engine.active_player_color)),
  ])
}

pub fn decoder() {
  use active_player_color <- decode.field(
    "active_player_color",
    color.decoder(),
  )

  use black <- decode.field("black", player.decoder())
  use board <- decode.field("board", board.decoder())
  use white <- decode.field("white", player.decoder())

  decode.success(Engine(
    active_player_color:,
    black:,
    board:,
    // TODO
    history: [],
    white:,
  ))
}

pub fn get_active_player(engine: Engine) {
  case engine.active_player_color {
    color.Black -> engine.black
    color.White -> engine.white
  }
}

pub fn update_active_player(engine: Engine, player: Player) {
  case engine.active_player_color {
    color.Black -> Engine(..engine, black: player)
    color.White -> Engine(..engine, white: player)
  }
}

pub fn commit(engine: Engine, turn: Turn) {
  use <- yuzu.true(turn.color == engine.active_player_color, Error(Nil))

  let turn_player = case turn.color {
    color.Black -> engine.black
    color.White -> engine.white
  }

  let capture =
    dict.get(engine.board.cells, turn.move.1)
    |> result.map(fn(cell) { cell.card })
    |> result.unwrap(option.None)

  use board <- yuzu.ok(
    move.commit(turn.move.0, turn.move.1, engine.board, turn.color),
    Error(Nil),
  )

  let marches =
    turn.marches
    |> list.prepend(turn.move.0)
    |> list.reverse()
    |> list.window_by_2()
    |> list.reverse()

  use board <- yuzu.ok(
    list.try_fold(marches, board, fn(board, march) {
      march.commit(march.0, march.1, board, turn.color)
    }),
    Error(Nil),
  )

  use #(turn_player, board) <- yuzu.ok(
    deploy.commit(turn.deploy, turn_player, board),
    Error(Nil),
  )

  use #(turn_player, drawn_cards) <- yuzu.ok(
    player.draw(turn_player),
    Error(Nil),
  )

  let history =
    drawn_cards
    |> list.map(HistoryDraw)
    |> list.prepend(HistoryTurn(
      color: turn.color,
      move: #(turn.move.0, turn.move.1, capture),
      marches: marches,
      deploy: turn.deploy,
    ))
    |> list.append(engine.history, _)

  let next_player = case turn.color {
    color.Black -> engine.white
    color.White -> engine.black
  }

  let next_player_has_deploy =
    board
    |> board.get_base_index(next_player.color)
    |> board.is_none(board, _)
    |> bool.and(!player.has_empty_hand(next_player))

  let next_player_has_moves =
    list.any(dict.values(engine.board.cells), fn(cell) {
      use card <- yuzu.some(cell.card, False)
      use <- yuzu.true(card.color == next_player.color, False)

      engine.board
      |> move.list_dest_indices(cell)
      |> list.is_empty()
      |> bool.negate()
    })

  let pass_next_player = !next_player_has_deploy && !next_player_has_moves

  let #(active_player_color, history) = case pass_next_player {
    True -> #(next_player.color, history)
    False -> #(turn_player.color, list.prepend(history, HistoryPass))
  }

  Engine(
    active_player_color:,
    black: case turn_player.color {
      color.Black -> turn_player
      color.White -> engine.black
    },
    board:,
    history:,
    white: case turn_player.color {
      color.Black -> engine.white
      color.White -> turn_player
    },
  )
  |> Ok()
}

pub fn deploy(engine: Engine, card: Option(Card)) {
  let active_player = get_active_player(engine)
  let base_index = board.get_base_index(engine.board, active_player.color)

  case card, dict.get(engine.board.cells, base_index) {
    option.None, Ok(Cell(_, _, option.Some(_))) -> Ok(engine)

    option.Some(card), Ok(Cell(_, _, option.None)) -> {
      use player <- yuzu.ok(player.deploy(active_player, card), Error(Nil))

      let board =
        [Cell(base_index, tile: tile.Normal, card: option.Some(card))]
        |> board.update(engine.board, _)

      Engine(..engine, board:)
      |> update_active_player(player)
      |> Ok()
    }

    _, _ -> Error(Nil)
  }
}
