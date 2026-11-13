import core/lobby.{type Lobby}
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

pub fn post_request_json() {
  json.null()
}

pub fn post_request_decoder() {
  decode.success(Nil)
}

pub fn post_response_json(lobby_id: String) {
  json.string(lobby_id)
}

pub fn post_response_decoder() {
  decode.string
}
