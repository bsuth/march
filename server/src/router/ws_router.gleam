import core/user.{type User}
import gleam/erlang/process
import gleam/json
import gleam/option
import glisten/socket
import ipc
import logging
import mist
import names.{type Names}
import router/ws_router/lobby_router
import router/ws_router/match_router
import router/ws_router/matchmaking_router
import router/ws_state.{type WebsocketState}
import ws_api

// -----------------------------------------------------------------------------
// Hooks
// -----------------------------------------------------------------------------

pub fn on_init(_conn: mist.WebsocketConnection, user: User, names: Names) {
  let subject = process.new_subject()

  #(
    ws_state.WebsocketState(names:, user:, subject:),
    process.new_selector()
      |> process.select(subject)
      |> option.Some(),
  )
}

pub fn on_close(_state: WebsocketState) {
  Nil
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------

pub fn handler(
  state: WebsocketState,
  message: mist.WebsocketMessage(ipc.Websocket),
  conn: mist.WebsocketConnection,
) {
  case message {
    mist.Text(text) -> text_handler(state, conn, text)
    mist.Binary(_) -> mist.continue(state)
    mist.Custom(custom) -> custom_handler(state, conn, custom)
    mist.Closed | mist.Shutdown -> mist.stop()
  }
}

fn text_handler(
  state: WebsocketState,
  conn: mist.WebsocketConnection,
  text: String,
) {
  logging.log(logging.Info, "WS " <> text)

  case json.parse(text, ws_api.decoder()) {
    Ok(ws_api.Message("lobby." <> subpath, payload)) ->
      lobby_router.handler(state, conn, subpath, payload)

    Ok(ws_api.Message("match." <> subpath, payload)) ->
      match_router.handler(state, conn, subpath, payload)

    // TODO: remove me
    Ok(ws_api.Message("matchmaking." <> subpath, payload)) ->
      matchmaking_router.handler(state, conn, subpath, payload)

    _ -> {
      logging.log(logging.Error, "invalid ws text message: " <> text)
      mist.continue(state)
    }
  }
}

fn custom_handler(
  state: WebsocketState,
  conn: mist.WebsocketConnection,
  custom: ipc.Websocket,
) {
  case custom {
    // TODO: REMOVE ME
    ipc.WebsocketMatched -> mist.continue(state)

    ipc.WebsocketJson(json) -> {
      case mist.send_text_frame(conn, json.to_string(json)) {
        Ok(_) -> mist.continue(state)
        Error(reason) -> {
          logging.log(logging.Error, socket.reason_to_string(reason))
          mist.continue(state)
        }
      }
    }
  }
}
