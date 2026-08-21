import actors/match_registry
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang/process
import ipc
import logging
import mist
import router/ws_state.{type WebsocketState}
import ws_api/ws_match
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

    _ -> {
      logging.log(logging.Error, "invalid ws path: match." <> path)
      mist.continue(state)
    }
  }
}

fn enter(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use match_id <- yuzu.ok(
    decode.run(payload, ws_match.enter_decoder()),
    mist.continue(state),
  )

  send_to_match(state, match_id, ipc.MatchEnter(state.user, state.subject))
}

fn exit(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use match_id <- yuzu.ok(
    decode.run(payload, ws_match.exit_decoder()),
    mist.continue(state),
  )

  send_to_match(state, match_id, ipc.MatchExit(state.user.id))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn send_to_match(state: WebsocketState, match_id: String, message: ipc.Match) {
  use match_subject <- yuzu.ok(
    match_registry.get(state.names, match_id),
    mist.continue(state),
  )

  process.send(match_subject, message)
  mist.continue(state)
}
