import core/user.{type User}
import engine/board.{type Board}
import engine/face.{type Face}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
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
// UPDATE.BOARD
// -----------------------------------------------------------------------------

pub type UpdateBoardPayload {
  UpdateBoardPayload(lobby_id: String, board: Board)
}

pub fn update_board_json(payload: UpdateBoardPayload) {
  ws_api.json(
    "lobby.update.board",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("board", board.json(payload.board)),
    ]),
  )
}

pub fn update_board_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use board <- decode.field("board", board.decoder())
  decode.success(UpdateBoardPayload(lobby_id, board))
}

// -----------------------------------------------------------------------------
// UPDATE.DOUBLES
// -----------------------------------------------------------------------------

pub type UpdateDoublesPayload {
  UpdateDoublesPayload(lobby_id: String, doubles: Bool)
}

pub fn update_doubles_json(payload: UpdateDoublesPayload) {
  ws_api.json(
    "lobby.update.doubles",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("doubles", json.bool(payload.doubles)),
    ]),
  )
}

pub fn update_doubles_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use doubles <- decode.field("doubles", decode.bool)
  decode.success(UpdateDoublesPayload(lobby_id, doubles))
}

// -----------------------------------------------------------------------------
// UPDATE.HAND_SIZE
// -----------------------------------------------------------------------------

pub type UpdateHandSizePayload {
  UpdateHandSizePayload(lobby_id: String, hand_size: Int)
}

pub fn update_hand_size_json(payload: UpdateHandSizePayload) {
  ws_api.json(
    "lobby.update.hand_size",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("hand_size", json.int(payload.hand_size)),
    ]),
  )
}

pub fn update_hand_size_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use hand_size <- decode.field("hand_size", decode.int)
  decode.success(UpdateHandSizePayload(lobby_id, hand_size))
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
// UPDATE.PLAYER
// -----------------------------------------------------------------------------

pub type UpdatePlayerPayload {
  UpdatePlayerPayload(lobby_id: String, user_id: String, player_index: Int)
}

pub fn update_player_json(payload: UpdatePlayerPayload) {
  ws_api.json(
    "lobby.update.player",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #("user_id", json.string(payload.user_id)),
      #("player_index", json.int(payload.player_index)),
    ]),
  )
}

pub fn update_player_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)
  use user_id <- decode.field("user_id", decode.string)
  use player_index <- decode.field("player_index", decode.int)
  decode.success(UpdatePlayerPayload(lobby_id, user_id, player_index))
}

// -----------------------------------------------------------------------------
// UPDATE.TRAITS
// -----------------------------------------------------------------------------

pub type UpdateTraitsPayload {
  UpdateTraitsPayload(lobby_id: String, traits: Dict(Face, List(Trait)))
}

pub fn update_traits_json(payload: UpdateTraitsPayload) {
  ws_api.json(
    "lobby.update.traits",
    json.object([
      #("lobby_id", json.string(payload.lobby_id)),
      #(
        "traits",
        json.dict(payload.traits, face.to_string, json.array(_, trait.json)),
      ),
    ]),
  )
}

pub fn update_traits_decoder() {
  use lobby_id <- decode.field("lobby_id", decode.string)

  use traits <- decode.field(
    "traits",
    decode.dict(face.decoder(), decode.list(trait.decoder())),
  )

  decode.success(UpdateTraitsPayload(lobby_id, traits))
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
