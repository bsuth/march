import core/user.{type User}
import engine.{type Engine, Engine}
import engine/player
import gleam/dynamic/decode
import gleam/json
import yuzu

pub type Match {
  Match(id: String, black: User, engine: Engine, visible: Bool, white: User)
}

pub fn json(match: Match) {
  json.object([
    #("id", json.string(match.id)),
    #("black", user.json(match.black)),
    #("engine", engine.json(match.engine)),
    #("visible", json.bool(match.visible)),
    #("white", user.json(match.white)),
  ])
}

pub fn decoder() {
  let user_decoder = user.decoder()

  use id <- decode.field("id", decode.string)
  use black <- decode.field("black", user_decoder)
  use engine <- decode.field("engine", engine.decoder())
  use visible <- decode.field("visible", decode.bool)
  use white <- decode.field("white", user_decoder)

  decode.success(Match(id:, black:, engine:, visible:, white:))
}

pub fn mask_players(match: Match, user: User) {
  use black <- yuzu.ok(
    case user.id == match.black.id {
      True -> player.to_controlled(match.engine.black)
      False -> Ok(player.to_observed(match.engine.black))
    },
    Error(Nil),
  )

  use white <- yuzu.ok(
    case user.id == match.white.id {
      True -> player.to_controlled(match.engine.white)
      False -> Ok(player.to_observed(match.engine.white))
    },
    Error(Nil),
  )

  Ok(Match(..match, engine: Engine(..match.engine, black:, white:)))
}
