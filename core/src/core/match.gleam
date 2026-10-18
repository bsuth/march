import core/engine
import core/engine/player
import core/engine/turn
import core/user.{type User}
import gleam/dynamic/decode
import gleam/json
import gleam/list

pub type Match {
  Match(
    id: String,
    engine_kernel: engine.Kernel,
    players: List(User),
    visible: Bool,
  )
}

pub fn json(match: Match) {
  json.object([
    #("id", json.string(match.id)),
    #("engine_kernel", engine.kernel_json(match.engine_kernel)),
    #("players", json.array(match.players, user.json)),
    #("visible", json.bool(match.visible)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use engine_kernel <- decode.field("engine_kernel", engine.kernel_decoder())
  use players <- decode.field("players", decode.list(user.decoder()))
  use visible <- decode.field("visible", decode.bool)
  decode.success(Match(id:, engine_kernel:, players:, visible:))
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
