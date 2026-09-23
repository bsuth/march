import core/user.{type User}
import engine.{type Engine, Engine}
import engine/player
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list

pub type Match {
  Match(id: String, engine: Engine, players: List(User), visible: Bool)
}

pub fn json(match: Match) {
  json.object([
    #("id", json.string(match.id)),
    #("engine", engine.json(match.engine)),
    #("players", json.array(match.players, user.json)),
    #("visible", json.bool(match.visible)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use engine <- decode.field("engine", engine.decoder())
  use players <- decode.field("players", decode.list(user.decoder()))
  use visible <- decode.field("visible", decode.bool)
  decode.success(Match(id:, engine:, players:, visible:))
}

pub fn mask(match: Match, user: User) {
  let user_player_index =
    match.players
    |> list.index_map(fn(player_user, index) { #(player_user.id, index) })
    |> list.find_map(fn(player_user_id_and_index_tuple) {
      case player_user_id_and_index_tuple.0 == user.id {
        True -> Ok(player_user_id_and_index_tuple.1)
        False -> Error(Nil)
      }
    })

  let engine_players =
    dict.map_values(match.engine.players, fn(index, player) {
      case user_player_index {
        Ok(user_player_index) if user_player_index == index -> {
          let assert Ok(user_player) = player.to_controlled(player)
          user_player
        }

        _ -> player.to_observed(player)
      }
    })

  Match(..match, engine: Engine(..match.engine, players: engine_players))
}
