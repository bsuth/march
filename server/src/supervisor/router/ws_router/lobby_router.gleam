import core/ws_api/ws_lobby
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
    "start" -> start(state, conn, payload)
    "terminate" -> terminate(state, conn, payload)
    "update.board" -> update_board(state, conn, payload)
    "update.doubles" -> update_doubles(state, conn, payload)
    "update.hand_size" -> update_hand_size(state, conn, payload)
    "update.mode" -> update_mode(state, conn, payload)
    "update.player_user_id" -> update_player_user_id(state, conn, payload)

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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id:,
    message: ipc.LobbyEnter(
      enter_user: state.user,
      enter_user_subject: state.subject,
    ),
  ))

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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id:,
    message: ipc.LobbyExit(exit_user_id: state.user.id),
  ))

  mist.continue(state)
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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id:,
    message: ipc.LobbyStart(request_user_id: state.user.id),
  ))

  mist.continue(state)
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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id:,
    message: ipc.LobbyTerminate(request_user_id: state.user.id),
  ))

  mist.continue(state)
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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id: payload.lobby_id,
    message: ipc.LobbyUpdateBoard(
      request_user_id: state.user.id,
      board: payload.board,
    ),
  ))

  mist.continue(state)
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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id: payload.lobby_id,
    message: ipc.LobbyUpdateDoubles(
      request_user_id: state.user.id,
      doubles: payload.doubles,
    ),
  ))

  mist.continue(state)
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

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id: payload.lobby_id,
    message: ipc.LobbyUpdateHandSize(
      request_user_id: state.user.id,
      hand_size: payload.hand_size,
    ),
  ))

  mist.continue(state)
}

fn update_mode(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_mode_decoder()),
    mist.continue(state),
  )

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id: payload.lobby_id,
    message: ipc.LobbyUpdateMode(
      request_user_id: state.user.id,
      mode: payload.mode,
    ),
  ))

  mist.continue(state)
}

fn update_player_user_id(
  state: WebsocketState,
  _conn: mist.WebsocketConnection,
  payload: Dynamic,
) {
  use payload <- yuzu.ok(
    decode.run(payload, ws_lobby.update_player_user_id_decoder()),
    mist.continue(state),
  )

  state.names.lobby_manager
  |> process.named_subject()
  |> process.send(ipc.LobbyManagerForward(
    lobby_id: payload.lobby_id,
    message: ipc.LobbyUpdatePlayerUserId(
      request_user_id: state.user.id,
      player_index: payload.player_index,
      user_id: payload.user_id,
    ),
  ))

  mist.continue(state)
}
