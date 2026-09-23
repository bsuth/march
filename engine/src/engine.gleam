import engine/card
import engine/player.{type Player}
import engine/position.{type Position}
import engine/settings.{type Settings}
import engine/turn.{type Turn}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option

pub type Engine {
  Engine(
    active_player_index: Int,
    players: Dict(Int, Player),
    position: Position,
    seeds: Dict(Int, Player),
    settings: Settings,
    turns: List(Turn),
  )
}

pub fn new(settings: Settings) {
  let num_players = case settings.doubles {
    True -> 4
    False -> 2
  }

  let seeds =
    int.range(0, num_players, dict.new(), fn(players, index) {
      let #(hand, deck) =
        card.deck(index)
        |> list.shuffle()
        |> list.split(settings.hand_size)

      dict.insert(players, index, player.Managed(index, deck, hand))
    })

  let position =
    int.range(
      0,
      settings.board.width * settings.board.height,
      dict.new(),
      fn(position, index) { dict.insert(position, index, option.None) },
    )

  Engine(
    active_player_index: 0,
    players: seeds,
    position:,
    seeds:,
    settings:,
    turns: [],
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(engine: Engine) {
  json.object([
    #("active_player_index", json.int(engine.active_player_index)),
    #(
      "players",
      dict.to_list(engine.players)
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(fn(entry) { entry.1 })
        |> json.array(player.json),
    ),
    #("position", position.json(engine.position)),
    #(
      "seeds",
      dict.to_list(engine.seeds)
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(fn(entry) { entry.1 })
        |> json.array(player.json),
    ),
    #("settings", settings.json(engine.settings)),
  ])
}

pub fn decoder() {
  use active_player_index <- decode.field("active_player_index", decode.int)

  use players <- decode.field(
    "players",
    player.decoder()
      |> decode.list()
      |> decode.map(fn(positions) {
        positions
        |> list.index_map(fn(position, index) { #(index, position) })
        |> dict.from_list()
      }),
  )

  use position <- decode.field("position", position.decoder())

  use seeds <- decode.field(
    "seeds",
    player.decoder()
      |> decode.list()
      |> decode.map(fn(positions) {
        positions
        |> list.index_map(fn(position, index) { #(index, position) })
        |> dict.from_list()
      }),
  )

  use settings <- decode.field("settings", settings.decoder())
  use turns <- decode.field("turns", decode.list(turn.decoder()))

  decode.success(Engine(
    active_player_index:,
    players:,
    position:,
    seeds:,
    settings:,
    turns:,
  ))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn turn(engine: Engine, turn: Turn) {
  let assert Ok(active_player) =
    dict.get(engine.players, engine.active_player_index)

  let #(active_player, position) =
    turn.apply(turn, active_player, engine.position, engine.settings)

  let players =
    dict.insert(engine.players, engine.active_player_index, active_player)

  Engine(..engine, players:, position:)
}
