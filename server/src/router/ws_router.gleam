import gleam/erlang/process
import gleam/json
import gleam/option
import ipc
import logging
import mist
import names.{type Names}
import router/ws_router/lobby_router
import router/ws_router/matchmaking_router
import router/ws_state.{type WebsocketState}
import ws_api
import ws_api/ws_lobby

// -----------------------------------------------------------------------------
// Hooks
// -----------------------------------------------------------------------------

pub fn on_init(_conn: mist.WebsocketConnection, user_id: String, names: Names) {
  let subject = process.new_subject()

  #(
    ws_state.WebsocketState(user_id:, names:, subject:),
    process.new_selector()
      |> process.select(subject)
      |> option.Some(),
  )
}

pub fn on_close(state: WebsocketState) {
  state.names.matchmaker
  |> process.named_subject()
  |> process.send(ipc.MatchmakerExit(state.subject))
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
  case json.parse(text, ws_api.decoder()) {
    Ok(ws_api.Message("matchmaking." <> subpath, payload)) ->
      matchmaking_router.handler(state, conn, subpath, payload)

    Ok(ws_api.Message("lobby." <> subpath, payload)) ->
      lobby_router.handler(state, conn, subpath, payload)

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

    // TODO: move me to a proper router?
    ipc.WebsocketLobbyUpdate(lobby) -> {
      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          lobby
            |> ws_lobby.update_json()
            |> json.to_string(),
        )
      mist.continue(state)
    }

    ipc.WebsocketLobbyUpdateName(lobby_id, name) -> {
      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          ws_lobby.UpdateNamePayload(lobby_id, name)
            |> ws_lobby.update_name_json()
            |> json.to_string(),
        )
      mist.continue(state)
    }

    ipc.WebsocketLobbyUpdateBoard(lobby_id, width, height) -> {
      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          ws_lobby.UpdateBoardPayload(lobby_id, width, height)
            |> ws_lobby.update_board_json()
            |> json.to_string(),
        )
      mist.continue(state)
    }

    ipc.WebsocketLobbyUpdateVariant(lobby_id, variant) -> {
      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          ws_lobby.UpdateVariantPayload(lobby_id, variant)
            |> ws_lobby.update_variant_json()
            |> json.to_string(),
        )
      mist.continue(state)
    }

    ipc.WebsocketLobbyUpdateVisibility(lobby_id, visible) -> {
      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          ws_lobby.UpdateVisibilityPayload(lobby_id, visible)
            |> ws_lobby.update_visibility_json()
            |> json.to_string(),
        )
      mist.continue(state)
    }
  }
}
