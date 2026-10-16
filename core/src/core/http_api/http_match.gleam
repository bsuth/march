import core/match.{type Match}
import gleam/dynamic/decode
import gleam/json

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub fn get_request_json(match_id: String) {
  json.string(match_id)
}

pub fn get_request_decoder() {
  decode.string
}

pub type GetResponse {
  GetResponse(match: Match)
}

pub fn get_response_json(match: Match) {
  match.json(match)
}

pub fn get_response_decoder() {
  match.decoder()
}
