import engine/variant.{type Variant}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

pub type LobbyEntity {
  LobbyEntity(
    id: String,
    name: String,
    is_public: Bool,
    variant: Variant,
    board_width: Int,
    board_height: Int,
    owner_user_id: String,
    black_user_id: Option(String),
    white_user_id: Option(String),
    spectator_user_ids: List(String),
  )
}

pub fn json(entity: LobbyEntity) {
  json.object([
    #("id", json.string(entity.id)),
    #("name", json.string(entity.name)),
    #("is_public", json.bool(entity.is_public)),
    #("variant", variant.json(entity.variant)),
    #("board_width", json.int(entity.board_width)),
    #("board_height", json.int(entity.board_height)),
    #("owner_user_id", json.string(entity.owner_user_id)),
    #("black_user_id", case entity.black_user_id {
      option.None -> json.null()
      option.Some(black_user_id) -> json.string(black_user_id)
    }),
    #("white_user_id", case entity.white_user_id {
      option.None -> json.null()
      option.Some(white_user_id) -> json.string(white_user_id)
    }),
    #("spectator_user_ids", json.array(entity.spectator_user_ids, json.string)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use is_public <- decode.field("is_public", decode.bool)
  use variant <- decode.field("variant", variant.decoder())
  use board_width <- decode.field("board_width", decode.int)
  use board_height <- decode.field("board_height", decode.int)
  use owner_user_id <- decode.field("owner_user_id", decode.string)
  use black_user_id <- decode.field(
    "black_user_id",
    decode.optional(decode.string),
  )
  use white_user_id <- decode.field(
    "white_user_id",
    decode.optional(decode.string),
  )
  use spectator_user_ids <- decode.field(
    "spectator_user_ids",
    decode.list(decode.string),
  )

  decode.success(LobbyEntity(
    id:,
    name:,
    is_public:,
    variant:,
    board_width:,
    board_height:,
    owner_user_id:,
    black_user_id:,
    white_user_id:,
    spectator_user_ids:,
  ))
}
