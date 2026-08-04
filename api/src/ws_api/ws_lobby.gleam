import engine/variant.{type Variant}
import entities/lobby_entity.{type LobbyEntity}
import gleam/dynamic/decode
import gleam/json
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
// EXIT
// -----------------------------------------------------------------------------

pub fn exit_json(lobby_id: String) {
  ws_api.json("lobby.exit", json.string(lobby_id))
}

pub fn exit_decoder() {
  decode.string
}

// -----------------------------------------------------------------------------
// UPDATE
// -----------------------------------------------------------------------------

pub fn update_json(lobby: LobbyEntity) {
  ws_api.json("lobby.update", lobby_entity.json(lobby))
}

pub fn update_decoder() {
  lobby_entity.decoder()
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
