import core/user.{type User}
import engine/variant.{type Variant}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import yuzu

pub type Lobby {
  Lobby(
    id: String,
    black: Option(User),
    board_height: Int,
    board_width: Int,
    match_id: Option(String),
    name: String,
    owner: User,
    users: List(User),
    variant: Variant,
    visible: Bool,
    white: Option(User),
  )
}

pub fn json(lobby: Lobby) {
  json.object([
    #("id", json.string(lobby.id)),
    #("black", json.nullable(lobby.black, user.json)),
    #("board_height", json.int(lobby.board_height)),
    #("board_width", json.int(lobby.board_width)),
    #("match_id", json.nullable(lobby.match_id, json.string)),
    #("name", json.string(lobby.name)),
    #("owner", user.json(lobby.owner)),
    #("users", json.array(lobby.users, user.json)),
    #("variant", variant.json(lobby.variant)),
    #("visible", json.bool(lobby.visible)),
    #("white", json.nullable(lobby.white, user.json)),
  ])
}

pub fn decoder() {
  let user_decoder = user.decoder()

  use id <- decode.field("id", decode.string)
  use black <- decode.field("black", decode.optional(user_decoder))
  use board_height <- decode.field("board_height", decode.int)
  use board_width <- decode.field("board_width", decode.int)
  use match_id <- decode.field("match_id", decode.optional(decode.string))
  use name <- decode.field("name", decode.string)
  use owner <- decode.field("owner", user_decoder)
  use users <- decode.field("users", decode.list(user_decoder))
  use variant <- decode.field("variant", variant.decoder())
  use visible <- decode.field("visible", decode.bool)
  use white <- decode.field("white", decode.optional(user_decoder))

  decode.success(Lobby(
    id:,
    black:,
    board_height:,
    board_width:,
    match_id:,
    name:,
    owner:,
    users:,
    variant:,
    visible:,
    white:,
  ))
}

pub fn assign_black(lobby: Lobby, black_user_id: Option(String)) {
  use black_user_id <- yuzu.some(
    black_user_id,
    Ok(Lobby(..lobby, black: option.None)),
  )

  use black <- yuzu.ok(
    list.find(lobby.users, fn(user) { user.id == black_user_id }),
    Error(Nil),
  )

  let white = case lobby.white {
    option.Some(white) if white.id == black_user_id -> option.None
    _ -> lobby.white
  }

  Ok(Lobby(..lobby, white:, black: option.Some(black)))
}

pub fn assign_white(lobby: Lobby, white_user_id: Option(String)) {
  use white_user_id <- yuzu.some(
    white_user_id,
    Ok(Lobby(..lobby, white: option.None)),
  )

  use white <- yuzu.ok(
    list.find(lobby.users, fn(user) { user.id == white_user_id }),
    Error(Nil),
  )

  let black = case lobby.black {
    option.Some(black) if black.id == white_user_id -> option.None
    _ -> lobby.black
  }

  Ok(Lobby(..lobby, black:, white: option.Some(white)))
}

pub fn remove_user(lobby: Lobby, removed_user_id: String) {
  let black = case lobby.black {
    option.Some(black) if black.id == removed_user_id -> option.None
    _ -> lobby.black
  }

  let white = case lobby.white {
    option.Some(white) if white.id == removed_user_id -> option.None
    _ -> lobby.white
  }

  Lobby(
    ..lobby,
    black:,
    white:,
    users: list.filter(lobby.users, fn(user) { user.id != removed_user_id }),
  )
}
