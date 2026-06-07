import actors/lobby
import actors/lobby_registry
import core/yuzu
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option
import ipc
import mist
import names.{type Names}
import wisp

pub type State {
  WebsocketState(names: Names, subject: Subject(ipc.Websocket))
}

// -----------------------------------------------------------------------------
// Hooks
// -----------------------------------------------------------------------------

pub fn on_init(_conn: mist.WebsocketConnection, names: Names) {
  let subject = process.new_subject()

  #(
    WebsocketState(names:, subject:),
    process.new_selector()
      |> process.select(subject)
      |> option.Some(),
  )
}

pub fn on_close(state: State) {
  state.names.matchmaker
  |> process.named_subject()
  |> process.send(ipc.MatchmakerExit(state.subject))
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------

pub fn handler(
  state: State,
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

fn text_handler(state: State, conn: mist.WebsocketConnection, text: String) {
  let text_method_decoder = {
    use method <- decode.field("method", decode.string)
    use payload <- decode.field("payload", decode.dynamic)
    decode.success(#(method, payload))
  }

  case json.parse(from: text, using: text_method_decoder) {
    Ok(#("enter_matchmaking", _)) -> {
      state.names.matchmaker
      |> process.named_subject()
      |> process.send(ipc.MatchmakerEnter(state.subject))

      mist.continue(state)
    }

    Ok(#("exit_matchmaking", _)) -> {
      state.names.matchmaker
      |> process.named_subject()
      |> process.send(ipc.MatchmakerExit(state.subject))

      mist.continue(state)
    }

    Ok(#("get_lobby", dynamic_lobby_id)) -> {
      use lobby_id <- yuzu.ok(
        decode.run(dynamic_lobby_id, decode.string),
        mist.continue(state),
      )

      use lobby_subject <- yuzu.ok(
        lobby_registry.get(state.names, lobby_id),
        mist.continue(state),
      )

      let lobby_state = process.call_forever(lobby_subject, ipc.LobbyGetState)

      let assert Ok(_) =
        mist.send_text_frame(
          conn,
          json.object([
            #("event", json.string("lobby_state")),
            #("payload", json.string(lobby_state.id)),
          ])
            |> json.to_string(),
        )

      mist.continue(state)
    }

    Ok(#("create_lobby", _)) -> {
      case lobby.start(state.names) {
        Ok(actor) -> {
          let assert Ok(_) =
            mist.send_text_frame(
              conn,
              json.object([
                #("event", json.string("lobby_created")),
                #("payload", json.string(actor.data.id)),
              ])
                |> json.to_string(),
            )

          mist.continue(state)
        }

        Error(_) -> {
          mist.continue(state)
        }
      }
    }

    _ -> {
      wisp.log_error("invalid ws text message: " <> text)
      mist.continue(state)
    }
  }
}

fn custom_handler(
  state: State,
  conn: mist.WebsocketConnection,
  custom: ipc.Websocket,
) {
  case custom {
    ipc.WebsocketCreateLobby -> {
      case lobby.start(state.names) {
        Ok(actor) -> {
          let assert Ok(_) =
            mist.send_text_frame(
              conn,
              json.object([
                #("event", json.string("lobby_created")),
                #("payload", json.string(actor.data.id)),
              ])
                |> json.to_string(),
            )

          mist.continue(state)
        }

        Error(_) -> {
          mist.continue(state)
        }
      }
    }

    ipc.WebsocketBroadcast(text) -> {
      let assert Ok(_) = mist.send_text_frame(conn, text)
      mist.continue(state)
    }

    ipc.WebsocketMatched -> {
      let assert Ok(_) = mist.send_text_frame(conn, "matched")
      mist.continue(state)
    }
  }
}
