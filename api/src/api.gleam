import gleam/dynamic/decode
import gleam/json.{type Json}

// TODO: remove me?
pub fn request_json(method: String, payload: List(#(String, Json))) {
  json.object([
    #("type", json.string("request")),
    #("method", json.string(method)),
    #("payload", json.object(payload)),
  ])
}

pub type GetInitResponse {
  GetInitResponse(id: String)
}

pub fn get_init_response_json(response: GetInitResponse) {
  json.object([#("id", json.string(response.id))])
}

pub fn get_init_response_decoder() {
  use id <- decode.field("id", decode.string)
  decode.success(GetInitResponse(id:))
}

pub type PostLobbyRequest {
  PostLobbyRequest(name: String, public: Bool)
}

pub fn post_lobby_request_json(request: PostLobbyRequest) {
  json.object([
    #("name", json.string(request.name)),
    #("public", json.bool(request.public)),
  ])
}

pub fn post_lobby_request_decoder() {
  use name <- decode.field("name", decode.string)
  use public <- decode.field("public", decode.bool)
  decode.success(PostLobbyRequest(name:, public:))
}

pub type PostLobbyResponse {
  PostLobbyResponse(id: String)
}

pub fn post_lobby_response_json(response: PostLobbyResponse) {
  json.object([
    #("id", json.string(response.id)),
  ])
}

pub fn post_lobby_response_decoder() {
  use id <- decode.field("id", decode.string)
  decode.success(PostLobbyResponse(id:))
}
