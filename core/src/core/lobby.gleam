import core/engine/settings.{
  type Settings as EngineSettings, Settings as EngineSettings,
} as engine_settings
import core/user.{type User}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import yuzu

pub type Lobby {
  Lobby(
    id: String,
    engine_settings: EngineSettings,
    owner_user_id: String,
    player_user_ids: List(Option(String)),
    users: List(User),
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(lobby: Lobby) {
  json.object([
    #("id", json.string(lobby.id)),
    #("engine_settings", engine_settings.json(lobby.engine_settings)),
    #("owner_user_id", json.string(lobby.owner_user_id)),
    #(
      "player_user_ids",
      json.array(lobby.player_user_ids, json.nullable(_, json.string)),
    ),
    #("users", json.array(lobby.users, user.json)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use engine_settings <- decode.field(
    "engine_settings",
    engine_settings.decoder(),
  )
  use owner_user_id <- decode.field("owner_user_id", decode.string)
  use player_user_ids <- decode.field(
    "player_user_ids",
    decode.list(decode.optional(decode.string)),
  )
  use users <- decode.field("users", decode.list(user.decoder()))

  decode.success(Lobby(
    id:,
    engine_settings:,
    owner_user_id:,
    player_user_ids:,
    users:,
  ))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn get_player_user_id(lobby: Lobby, player_index: Int) {
  case lobby.player_user_ids, player_index {
    [p1, ..], 0 -> Ok(p1)
    [_, p2, ..], 1 -> Ok(p2)
    [_, _, p3, ..], 2 -> Ok(p3)
    [_, _, _, p4], 3 -> Ok(p4)
    _, _ -> Error(Nil)
  }
}

pub fn remove_user(lobby: Lobby, removed_user_id: String) {
  let player_user_ids =
    list.map(lobby.player_user_ids, fn(player_user_id) {
      case player_user_id {
        option.Some(player_user_id) if player_user_id == removed_user_id ->
          option.None
        _ -> player_user_id
      }
    })

  Lobby(
    ..lobby,
    player_user_ids:,
    users: list.filter(lobby.users, fn(user) { user.id != removed_user_id }),
  )
}

pub fn set_doubles(lobby: Lobby, doubles: Bool) {
  let engine_settings = EngineSettings(..lobby.engine_settings, doubles:)

  let player_user_ids = case doubles, lobby.player_user_ids {
    True, [p1, p2] -> [p1, option.None, p2, option.None]
    False, [p1, _, p3, _] -> [p1, p3]
    _, _ -> lobby.player_user_ids
  }

  Lobby(..lobby, engine_settings:, player_user_ids:)
}

pub fn set_player_user_id(
  lobby: Lobby,
  player_index: Int,
  user_id: Option(String),
) {
  case user_id {
    option.None -> {
      let player_user_ids =
        list.index_map(lobby.player_user_ids, fn(player_user_id, index) {
          case index == player_index {
            True -> option.None
            False -> player_user_id
          }
        })

      Ok(Lobby(..lobby, player_user_ids:))
    }

    option.Some(user_id) -> {
      let player_user_ids =
        list.index_map(lobby.player_user_ids, fn(player_user_id, index) {
          use <- yuzu.false(index == player_index, option.Some(user_id))
          use player_user_id <- yuzu.some_(player_user_id)

          case player_user_id == user_id {
            True -> option.None
            False -> option.Some(player_user_id)
          }
        })

      Ok(Lobby(..lobby, player_user_ids:))
    }
  }
}
