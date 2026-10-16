import core/lobby.{type Lobby}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub type GetRequest {
  GetRequest(limit: Option(Int), offset: Option(Int))
}

pub fn get_request_json(request: GetRequest) {
  json.object([
    #("limit", json.nullable(request.limit, json.int)),
    #("offset", json.nullable(request.offset, json.int)),
  ])
}

pub fn get_request_decoder() {
  use limit <- decode.field("limit", decode.optional(decode.int))
  use offset <- decode.field("offset", decode.optional(decode.int))
  decode.success(GetRequest(limit:, offset:))
}

pub fn get_response_json(lobbies: List(Lobby)) {
  json.array(lobbies, lobby.json)
}

pub fn get_response_decoder() {
  lobby.decoder()
  |> decode.list()
}
