import core/ws_api/ws_match
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang/process
import ipc
import logging
import mist
import supervisor/router/ws_state.{type WebsocketState}
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
    "request_turn" -> request_turn(state, conn, payload)

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

  state.names.match_manager
  |> process.named_subject()
  |> process.send(ipc.MatchManagerForward(
    match_id,
    ipc.MatchEnter(state.user, state.subject),
  ))

  mist.continue(state)
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

  state.names.match_manager
  |> process.named_subject()
  |> process.send(ipc.MatchManagerForward(
    match_id,
    ipc.MatchExit(state.user.id),
  ))

  mist.continue(state)
}

fn request_turn(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_match.request_turn_decoder()),
    mist.continue(state),
  )

  state.names.match_manager
  |> process.named_subject()
  |> process.send(ipc.MatchManagerForward(
    payload.match_id,
    ipc.MatchRequestTurn(state.user.id, payload.turn_request),
  ))

  mist.continue(state)
}
