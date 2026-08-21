import core/user.{type User}
import gleam/dynamic/decode
import gleam/json
import ws_api

// -----------------------------------------------------------------------------
// ENTER
// -----------------------------------------------------------------------------

pub fn enter_json(match_id: String) {
  ws_api.json("match.enter", json.string(match_id))
}

pub fn enter_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// ENTERED
// -----------------------------------------------------------------------------

pub type EnteredPayload {
  EnteredPayload(match_id: String, user: User)
}

pub fn entered_json(payload: EnteredPayload) {
  ws_api.json(
    "match.entered",
    json.object([
      #("match_id", json.string(payload.match_id)),
      #("user", user.json(payload.user)),
    ]),
  )
}

pub fn entered_decoder() {
  use match_id <- decode.field("match_id", decode.string)
  use user <- decode.field("user", user.decoder())
  decode.success(EnteredPayload(match_id, user))
}

// -----------------------------------------------------------------------------
// EXIT
// -----------------------------------------------------------------------------

pub fn exit_json(match_id: String) {
  ws_api.json("match.exit", json.string(match_id))
}

pub fn exit_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// EXITED
// -----------------------------------------------------------------------------

pub type ExitedPayload {
  ExitedPayload(match_id: String, user_id: String)
}

pub fn exited_json(payload: ExitedPayload) {
  ws_api.json(
    "match.exited",
    json.object([
      #("match_id", json.string(payload.match_id)),
      #("user_id", json.string(payload.user_id)),
    ]),
  )
}

pub fn exited_decoder() {
  use match_id <- decode.field("match_id", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  decode.success(ExitedPayload(match_id, user_id))
}

// -----------------------------------------------------------------------------
// TERMINATED
// -----------------------------------------------------------------------------

pub fn terminated_json(match_id: String) {
  ws_api.json("match.terminated", json.string(match_id))
}

pub fn terminated_decoder() {
  decode.string
}
