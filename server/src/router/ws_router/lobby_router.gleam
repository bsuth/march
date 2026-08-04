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

pub fn handler(
  state: WebsocketState,
  conn: mist.WebsocketConnection,
  path: String,
  payload: Dynamic,
) {
  case path {
    "enter" -> enter(state, conn, payload)
    "exit" -> exit(state, conn, payload)
    "update" -> update(state, conn, payload)
    "update.board" -> update_board(state, conn, payload)
    "update.name" -> update_name(state, conn, payload)
    "update.variant" -> update_variant(state, conn, payload)
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

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyEnter(state.user_id, state.subject))

  mist.continue(state)
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

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyExit(state.user_id))

  mist.continue(state)
}

fn update(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  // TODO: ensure lobby owner

  use lobby <- yuzu.ok(
    decode.run(payload, ws_lobby.update_decoder()),
    mist.continue(state),
  )

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, lobby.id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyUpdate(lobby))

  mist.continue(state)
}

fn update_board(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  // TODO: ensure lobby owner

  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_board_decoder()),
    mist.continue(state),
  )

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, payload.lobby_id),
    mist.continue(state),
  )

  process.send(
    lobby_subject,
    ipc.LobbyUpdateBoard(payload.width, payload.height),
  )

  mist.continue(state)
}

fn update_name(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  // TODO: ensure lobby owner

  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_name_decoder()),
    mist.continue(state),
  )

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, payload.lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyUpdateName(payload.lobby_name))

  mist.continue(state)
}

fn update_variant(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  // TODO: ensure lobby owner

  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_variant_decoder()),
    mist.continue(state),
  )

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, payload.lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyUpdateVariant(payload.variant))

  mist.continue(state)
}

fn update_visibility(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  // TODO: ensure lobby owner

  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_visibility_decoder()),
    mist.continue(state),
  )

  use lobby_subject <- yuzu.ok(
    lobby_registry.get(state.names, payload.lobby_id),
    mist.continue(state),
  )

  process.send(lobby_subject, ipc.LobbyUpdateVisibility(payload.visible))

  mist.continue(state)
}
