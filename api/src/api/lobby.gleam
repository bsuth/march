import api
import gleam/dynamic/decode
import gleam/json

pub type CreateRequest {
  CreateRequest(name: String, public: Bool)
}

pub fn create_request_json(request: CreateRequest) {
  api.request_json("lobby.create", [
    #("name", json.string(request.name)),
    #("public", json.bool(request.public)),
  ])
}

pub fn create_request_decoder() {
  use name <- decode.field("name", decode.string)
  use public <- decode.field("public", decode.bool)
  decode.success(CreateRequest(name:, public:))
}
