import gleam/dynamic.{type Dynamic}
import gleam/erlang/process
import ipc
import logging
import mist
import router/ws_state.{type WebsocketState}

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
      logging.log(logging.Error, "invalid ws path: " <> path)
      mist.continue(state)
    }
  }
}

fn enter(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  _payload: Dynamic,
) {
  state.names.matchmaker
  |> process.named_subject()
  |> process.send(ipc.MatchmakerEnter(state.subject))

  mist.continue(state)
}

fn exit(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  _payload: Dynamic,
) {
  state.names.matchmaker
  |> process.named_subject()
  |> process.send(ipc.MatchmakerExit(state.subject))

  mist.continue(state)
}
