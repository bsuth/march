import core/lobby.{type Lobby}
import engine/settings.{type Settings as EngineSettings} as engine_settings
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
  PostRequest(engine_settings: EngineSettings, name: String, visible: Bool)
}

pub fn post_request_json(request: PostRequest) {
  json.object([
    #("engine_settings", engine_settings.json(request.engine_settings)),
    #("name", json.string(request.name)),
    #("visible", json.bool(request.visible)),
  ])
}

pub fn post_request_decoder() {
  use engine_settings <- decode.field(
    "engine_settings",
    engine_settings.decoder(),
  )
  use name <- decode.field("name", decode.string)
  use visible <- decode.field("visible", decode.bool)
  decode.success(PostRequest(engine_settings:, name:, visible:))
}

pub fn post_response_json(lobby: Lobby) {
  lobby.json(lobby)
}

pub fn post_response_decoder() {
  lobby.decoder()
}
