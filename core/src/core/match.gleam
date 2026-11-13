import core/engine
import core/engine/player
import core/engine/turn
import core/user.{type User}
import gleam/dynamic/decode
import gleam/json
import gleam/list

pub type Match {
  Match(id: String, engine_kernel: engine.Kernel, player_user_ids: List(String))
}

pub fn json(match: Match) {
  json.object([
    #("id", json.string(match.id)),
    #("engine_kernel", engine.kernel_json(match.engine_kernel)),
    #("player_user_ids", json.array(match.player_user_ids, json.string)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use engine_kernel <- decode.field("engine_kernel", engine.kernel_decoder())
  use player_user_ids <- decode.field(
    "player_user_ids",
    decode.list(decode.string),
  )
  decode.success(Match(id:, engine_kernel:, player_user_ids:))
}

pub fn mask(match: Match, user: User) {
  let user_player_index =
    match.player_user_ids
    |> list.index_map(fn(player_user_id, index) { #(player_user_id, index) })
    |> list.find_map(fn(player_user_id_and_index_tuple) {
      case player_user_id_and_index_tuple.0 == user.id {
        True -> Ok(player_user_id_and_index_tuple.1)
        False -> Error(Nil)
      }
    })

  let player_seeds =
    list.index_map(match.engine_kernel.player_seeds, fn(player, index) {
      case user_player_index == Ok(index) {
        True -> {
          let assert Ok(user_player) = player.to_controlled(player)
          user_player
        }

        False -> player.to_observed(player)
      }
    })

  let turns =
    list.map(match.engine_kernel.turns, fn(turn) {
      case user_player_index == Ok(turn.player_index) {
        True -> turn
        False -> turn.to_observed(turn)
      }
    })

  Match(
    ..match,
    engine_kernel: engine.Kernel(..match.engine_kernel, player_seeds:, turns:),
  )
}
