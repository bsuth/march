import engine/variant.{type Variant}
import entities/lobby_entity.{type LobbyEntity}
import gleam/dynamic/decode
import gleam/json

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub type GetRequest {
  GetRequest(id: String)
}

pub fn get_request_json(request: GetRequest) {
  json.object([
    #("id", json.string(request.id)),
  ])
}

pub fn get_request_decoder() {
  use id <- decode.field("id", decode.string)
  decode.success(GetRequest(id:))
}

pub type GetResponse {
  GetResponse(lobby: LobbyEntity)
}

pub fn get_response_json(response: GetResponse) {
  lobby_entity.json(response.lobby)
}

pub fn get_response_decoder() {
  decode.map(lobby_entity.decoder(), GetResponse)
}

// -----------------------------------------------------------------------------
// POST
// -----------------------------------------------------------------------------

pub type PostRequest {
  PostRequest(
    name: String,
    is_public: Bool,
    variant: Variant,
    board_width: Int,
    board_height: Int,
  )
}

pub fn post_request_json(request: PostRequest) {
  json.object([
    #("name", json.string(request.name)),
    #("is_public", json.bool(request.is_public)),
    #("variant", variant.json(request.variant)),
    #("board_width", json.int(request.board_width)),
    #("board_height", json.int(request.board_height)),
  ])
}

pub fn post_request_decoder() {
  use name <- decode.field("name", decode.string)
  use is_public <- decode.field("is_public", decode.bool)
  use variant <- decode.field("variant", variant.decoder())
  use board_width <- decode.field("board_width", decode.int)
  use board_height <- decode.field("board_height", decode.int)

  decode.success(PostRequest(
    name:,
    is_public:,
    variant:,
    board_width:,
    board_height:,
  ))
}

pub type PostResponse {
  PostResponse(lobby: LobbyEntity)
}

pub fn post_response_json(response: PostResponse) {
  lobby_entity.json(response.lobby)
}

pub fn post_response_decoder() {
  decode.map(lobby_entity.decoder(), PostResponse)
}
