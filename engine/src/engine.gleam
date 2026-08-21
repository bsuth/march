import engine/board.{type Board}
import engine/card.{type Card}
import engine/color.{type Color}
import engine/deploy
import engine/march
import engine/move
import engine/player.{type Player}
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

pub type HistoryItem {
  Draw(Card)

  HistoryTurn(
    color: Color,
    move: #(Int, Int, Option(Card)),
    marches: List(#(Int, Int)),
    deploy: Option(Card),
  )

  // The player is not able to make any valid moves
  Pass
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

pub fn commit(engine: Engine, turn: Turn) {
  use <- yuzu.true(turn.color == engine.active_player_color, Error(Nil))

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

  let turn_player = case turn.color {
    color.Black -> engine.black
    color.White -> engine.white
  }

  use #(turn_player, board) <- yuzu.ok(
    deploy.commit(turn.deploy, turn_player, board),
    Error(Nil),
  )

  // TODO: auto-pass if new active player has no moves?
  let active_player_color = case turn.color {
    color.Black -> color.White
    color.White -> color.Black
  }

  let history =
    list.prepend(
      engine.history,
      HistoryTurn(
        color: turn.color,
        move: #(turn.move.0, turn.move.1, capture),
        marches: marches,
        deploy: turn.deploy,
      ),
    )

  // TODO: add card draw history
  use turn_player <- yuzu.ok(player.draw(turn_player), Error(Nil))

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
