import actors/lobby_registry
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang/process
import ipc
import logging
import mist
import router/ws_state.{type WebsocketState}
import ws_api/ws_lobby
import yuzu

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------

pub fn handler(
  state: WebsocketState,
  conn: mist.WebsocketConnection,
  path: String,
  payload: Dynamic,
) {
  case path {
    "enter" -> enter(state, conn, payload)
    "exit" -> exit(state, conn, payload)
    "start" -> start(state, conn, payload)
    "terminate" -> terminate(state, conn, payload)
    "update.board" -> update_board(state, conn, payload)
    "update.doubles" -> update_doubles(state, conn, payload)
    "update.hand_size" -> update_hand_size(state, conn, payload)
    "update.name" -> update_name(state, conn, payload)
    "update.player" -> update_player(state, conn, payload)
    "update.traits" -> update_traits(state, conn, payload)
    "update.visibility" -> update_visibility(state, conn, payload)

    _ -> {
      logging.log(logging.Error, "invalid ws path: lobby." <> path)
      mist.continue(state)
    }
  }
}

fn enter(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use lobby_id <- yuzu.ok(
    decode.run(payload, ws_lobby.enter_decoder()),
    mist.continue(state),
  )

  send_to_lobby(state, lobby_id, ipc.LobbyEnter(state.user, state.subject))
}

fn exit(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use lobby_id <- yuzu.ok(
    decode.run(payload, ws_lobby.exit_decoder()),
    mist.continue(state),
  )

  send_to_lobby(state, lobby_id, ipc.LobbyExit(state.user.id))
}

fn start(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use lobby_id <- yuzu.ok(
    decode.run(payload, ws_lobby.start_decoder()),
    mist.continue(state),
  )

  send_to_lobby(state, lobby_id, ipc.LobbyStart(state.user.id))
}

fn terminate(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use lobby_id <- yuzu.ok(
    decode.run(payload, ws_lobby.terminate_decoder()),
    mist.continue(state),
  )

  send_to_lobby(state, lobby_id, ipc.LobbyTerminate(state.user.id))
}

fn update_board(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_board_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateBoard(state.user.id, payload.board),
  )
}

fn update_doubles(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_doubles_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateDoubles(state.user.id, payload.doubles),
  )
}

fn update_hand_size(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_hand_size_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateHandSize(state.user.id, payload.hand_size),
  )
}

fn update_name(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_name_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateName(state.user.id, payload.lobby_name),
  )
}

fn update_player(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_player_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdatePlayer(state.user.id, payload.user_id, payload.player_index),
  )
}

fn update_traits(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_traits_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateTraits(state.user.id, payload.traits),
  )
}

fn update_visibility(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_visibility_decoder()),
    mist.continue(state),
  )

  send_to_lobby(
    state,
    payload.lobby_id,
    ipc.LobbyUpdateVisibility(state.user.id, payload.visible),
  )
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn send_to_lobby(state: WebsocketState, lobby_id: String, message: ipc.Lobby) {
  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, message)
  mist.continue(state)
}
