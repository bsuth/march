import gleam/dynamic/decode
import gleam/json

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub type GetResponse {
  GetResponse(id: String)
}

pub fn get_response_json(response: GetResponse) {
  json.object([#("id", json.string(response.id))])
}

pub fn get_response_decoder() {
  use id <- decode.field("id", decode.string)
  decode.success(GetResponse(id:))
}
