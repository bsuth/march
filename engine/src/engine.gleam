import engine/board.{type Board}
import engine/player.{type Player}
import engine/settings.{type Settings}
import engine/turn.{type Turn}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json

pub type Engine {
  Engine(
    active_player_index: Int,
    board: Board,
    players: Dict(Int, Player),
    seeds: Dict(Int, Player),
    settings: Settings,
    turns: List(Turn),
  )
}

pub fn json(engine: Engine) {
  json.object([
    #("active_player_index", json.int(engine.active_player_index)),
    #("board", board.json(engine.board)),
    #("players", json.dict(engine.players, int.to_string, player.json)),
    #("seeds", json.dict(engine.players, int.to_string, player.json)),
    #("settings", settings.json(engine.settings)),
  ])
}

pub fn decoder() {
  use active_player_index <- decode.field("active_player_index", decode.int)
  use board <- decode.field("board", board.decoder())
  use settings <- decode.field("settings", settings.decoder())
  use turns <- decode.field("turns", decode.list(turn.decoder()))

  use players <- decode.field(
    "players",
    decode.dict(
      decode.then(decode.string, fn(key) {
        case int.parse(key) {
          Ok(index) -> decode.success(index)
          Error(_) -> decode.failure(0, "player index")
        }
      }),
      player.decoder(),
    ),
  )

  use seeds <- decode.field(
    "seeds",
    decode.dict(
      decode.then(decode.string, fn(key) {
        case int.parse(key) {
          Ok(index) -> decode.success(index)
          Error(_) -> decode.failure(0, "seed index")
        }
      }),
      player.decoder(),
    ),
  )

  decode.success(Engine(
    active_player_index:,
    board:,
    players:,
    seeds:,
    settings:,
    turns:,
  ))
}
