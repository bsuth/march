import core/user.{type User}
import engine/variant.{type Variant}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import ws_api

// -----------------------------------------------------------------------------
// ENTER
// -----------------------------------------------------------------------------

pub fn enter_json(lobby_id: String) {
  ws_api.json("lobby.enter", json.string(lobby_id))
}

pub fn enter_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// ENTERED
// -----------------------------------------------------------------------------

pub type EnteredPayload {
  EnteredPayload(lobby_id: String, user: User)
}

pub fn entered_json(payload: EnteredPayload) {
  ws_api.json(
    "lobby.entered",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("user", user.json(payload.user)),
    ]),
  )
}

pub fn entered_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use user <- decode.field("user", user.decoder())
  decode.success(EnteredPayload(lobby_id, user))
}

// -----------------------------------------------------------------------------
// EXIT
// -----------------------------------------------------------------------------

pub fn exit_json(lobby_id: String) {
  ws_api.json("lobby.exit", json.string(lobby_id))
}

pub fn exit_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// EXITED
// -----------------------------------------------------------------------------

pub type ExitedPayload {
  ExitedPayload(lobby_id: String, user_id: String)
}

pub fn exited_json(payload: ExitedPayload) {
  ws_api.json(
    "lobby.exited",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("user_id", json.string(payload.user_id)),
    ]),
  )
}

pub fn exited_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  decode.success(ExitedPayload(lobby_id, user_id))
}

// -----------------------------------------------------------------------------
// START
// -----------------------------------------------------------------------------

pub fn start_json(lobby_id: String) {
  ws_api.json("lobby.start", json.string(lobby_id))
}

pub fn start_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// STARTED
// -----------------------------------------------------------------------------

pub type StartedPayload {
  StartedPayload(lobby_id: String, match_id: String)
}

pub fn started_json(payload: StartedPayload) {
  ws_api.json(
    "lobby.started",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("match_id", json.string(payload.match_id)),
    ]),
  )
}

pub fn started_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use match_id <- decode.field("match_id", decode.string)
  decode.success(StartedPayload(lobby_id, match_id))
}

// -----------------------------------------------------------------------------
// TERMINATE
// -----------------------------------------------------------------------------

pub fn terminate_json(lobby_id: String) {
  ws_api.json("lobby.terminate", json.string(lobby_id))
}

pub fn terminate_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// TERMINATED
// -----------------------------------------------------------------------------

pub fn terminated_json(lobby_id: String) {
  ws_api.json("lobby.terminated", json.string(lobby_id))
}

pub fn terminated_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// UPDATE.BLACK
// -----------------------------------------------------------------------------

pub type UpdateBlackPayload {
  UpdateBlackPayload(lobby_id: String, black_user_id: Option(String))
}

pub fn update_black_json(payload: UpdateBlackPayload) {
  ws_api.json(
    "lobby.update.black",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("black_user_id", json.nullable(payload.black_user_id, json.string)),
    ]),
  )
}

pub fn update_black_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use black_user_id <- decode.field(
    "black_user_id",
    decode.optional(decode.string),
  )

  decode.success(UpdateBlackPayload(lobby_id, black_user_id))
}

// -----------------------------------------------------------------------------
// UPDATE.BOARD
// -----------------------------------------------------------------------------

pub type UpdateBoardPayload {
  UpdateBoardPayload(lobby_id: String, width: Int, height: Int)
}

pub fn update_board_json(payload: UpdateBoardPayload) {
  ws_api.json(
    "lobby.update.board",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("width", json.int(payload.width)),
      #("height", json.int(payload.height)),
    ]),
  )
}

pub fn update_board_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)
  decode.success(UpdateBoardPayload(lobby_id, width, height))
}

// -----------------------------------------------------------------------------
// UPDATE.NAME
// -----------------------------------------------------------------------------

pub type UpdateNamePayload {
  UpdateNamePayload(lobby_id: String, lobby_name: String)
}

pub fn update_name_json(payload: UpdateNamePayload) {
  ws_api.json(
    "lobby.update.name",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("lobby_name", json.string(payload.lobby_name)),
    ]),
  )
}

pub fn update_name_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use lobby_name <- decode.field("lobby_name", decode.string)
  decode.success(UpdateNamePayload(lobby_id, lobby_name))
}

// -----------------------------------------------------------------------------
// UPDATE.VARIANT
// -----------------------------------------------------------------------------

pub type UpdateVariantPayload {
  UpdateVariantPayload(lobby_id: String, variant: Variant)
}

pub fn update_variant_json(payload: UpdateVariantPayload) {
  ws_api.json(
    "lobby.update.variant",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("variant", variant.json(payload.variant)),
    ]),
  )
}

pub fn update_variant_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use variant <- decode.field("variant", variant.decoder())
  decode.success(UpdateVariantPayload(lobby_id, variant))
}

// -----------------------------------------------------------------------------
// UPDATE.VISIBILITY
// -----------------------------------------------------------------------------

pub type UpdateVisibilityPayload {
  UpdateVisibilityPayload(lobby_id: String, visible: Bool)
}

pub fn update_visibility_json(payload: UpdateVisibilityPayload) {
  ws_api.json(
    "lobby.update.visibility",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("visible", json.bool(payload.visible)),
    ]),
  )
}

pub fn update_visibility_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use visible <- decode.field("visible", decode.bool)
  decode.success(UpdateVisibilityPayload(lobby_id, visible))
}

// -----------------------------------------------------------------------------
// UPDATE.WHITE
// -----------------------------------------------------------------------------

pub type UpdateWhitePayload {
  UpdateWhitePayload(lobby_id: String, white_user_id: Option(String))
}

pub fn update_white_json(payload: UpdateWhitePayload) {
  ws_api.json(
    "lobby.update.white",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("white_user_id", json.nullable(payload.white_user_id, json.string)),
    ]),
  )
}

pub fn update_white_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use white_user_id <- decode.field(
    "white_user_id",
    decode.optional(decode.string),
  )

  decode.success(UpdateWhitePayload(lobby_id, white_user_id))
}
