import core/user.{type User}
import engine/settings.{
  type Settings as EngineSettings, Settings as EngineSettings,
} as engine_settings
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import yuzu

pub type Lobby {
  Lobby(
    id: String,
    engine_settings: EngineSettings,
    match_id: Option(String),
    name: String,
    owner: User,
    players: List(Option(User)),
    users: List(User),
    visible: Bool,
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(lobby: Lobby) {
  json.object([
    #("id", json.string(lobby.id)),
    #("engine_settings", engine_settings.json(lobby.engine_settings)),
    #("match_id", json.nullable(lobby.match_id, json.string)),
    #("name", json.string(lobby.name)),
    #("owner", user.json(lobby.owner)),
    #("players", json.array(lobby.players, json.nullable(_, user.json))),
    #("users", json.array(lobby.users, user.json)),
    #("visible", json.bool(lobby.visible)),
  ])
}

pub fn decoder() {
  let user_decoder = user.decoder()

  use id <- decode.field("id", decode.string)

  use engine_settings <- decode.field(
    "engine_settings",
    engine_settings.decoder(),
  )

  use match_id <- decode.field("match_id", decode.optional(decode.string))
  use name <- decode.field("name", decode.string)
  use owner <- decode.field("owner", user_decoder)

  use players <- decode.field(
    "players",
    decode.list(decode.optional(user.decoder())),
  )

  use users <- decode.field("users", decode.list(user_decoder))
  use visible <- decode.field("visible", decode.bool)

  decode.success(Lobby(
    id:,
    engine_settings:,
    match_id:,
    name:,
    owner:,
    players:,
    users:,
    visible:,
  ))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn get_player_by_index(lobby: Lobby, player_index: Int) {
  case lobby.players, player_index {
    [p1, ..], 0 -> Ok(p1)
    [_, p2, ..], 1 -> Ok(p2)
    [_, _, p3, ..], 2 -> Ok(p3)
    [_, _, _, p4], 3 -> Ok(p4)
    _, _ -> Error(Nil)
  }
}

pub fn set_doubles(lobby: Lobby, doubles: Bool) {
  let engine_settings = EngineSettings(..lobby.engine_settings, doubles:)

  let players = case doubles, lobby.players {
    True, [p1, p2] -> [p1, option.None, p2, option.None]
    False, [p1, _, p3, _] -> [p1, p3]
    _, _ -> lobby.players
  }

  Lobby(..lobby, engine_settings:, players:)
}

pub fn set_player_index(
  lobby: Lobby,
  player_index: Int,
  user_id: Option(String),
) {
  case user_id {
    option.None -> {
      let players =
        list.index_map(lobby.players, fn(player_user, index) {
          case index == player_index {
            True -> option.None
            False -> player_user
          }
        })

      Ok(Lobby(..lobby, players:))
    }

    option.Some(user_id) -> {
      use user <- yuzu.ok(
        list.find(lobby.users, fn(user) { user.id == user_id }),
        Error(Nil),
      )

      let players =
        list.index_map(lobby.players, fn(player_user, index) {
          use <- yuzu.false(index == player_index, option.Some(user))
          use player_user <- yuzu.some_(player_user)

          case player_user.id == user.id {
            True -> option.None
            False -> option.Some(player_user)
          }
        })

      Ok(Lobby(..lobby, players:))
    }
  }
}

pub fn remove_user(lobby: Lobby, removed_user_id: String) {
  let players =
    list.map(lobby.players, fn(player_user) {
      case player_user {
        option.Some(player_user) if player_user.id == removed_user_id ->
          option.None
        _ -> player_user
      }
    })

  Lobby(
    ..lobby,
    players:,
    users: list.filter(lobby.users, fn(user) { user.id != removed_user_id }),
  )
}
