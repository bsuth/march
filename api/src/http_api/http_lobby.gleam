import core/lobby.{type Lobby}
import engine/variant.{type Variant}
import gleam/dynamic/decode
import gleam/json

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub fn get_request_json(lobby_id: String) {
  json.string(lobby_id)
}

pub fn get_request_decoder() {
  decode.string
}

pub fn get_response_json(lobby: Lobby) {
  lobby.json(lobby)
}

pub fn get_response_decoder() {
  lobby.decoder()
}

// -----------------------------------------------------------------------------
// POST
// -----------------------------------------------------------------------------

pub type PostRequest {
  PostRequest(
    board_height: Int,
    board_width: Int,
    name: String,
    variant: Variant,
    visible: Bool,
  )
}

pub fn post_request_json(request: PostRequest) {
  json.object([
    #("board_height", json.int(request.board_height)),
    #("board_width", json.int(request.board_width)),
    #("name", json.string(request.name)),
    #("variant", variant.json(request.variant)),
    #("visible", json.bool(request.visible)),
  ])
}

pub fn post_request_decoder() {
  use board_height <- decode.field("board_height", decode.int)
  use board_width <- decode.field("board_width", decode.int)
  use name <- decode.field("name", decode.string)
  use variant <- decode.field("variant", variant.decoder())
  use visible <- decode.field("visible", decode.bool)

  decode.success(PostRequest(
    board_height:,
    board_width:,
    name:,
    variant:,
    visible:,
  ))
}

pub fn post_response_json(lobby: Lobby) {
  lobby.json(lobby)
}

pub fn post_response_decoder() {
  lobby.decoder()
}
