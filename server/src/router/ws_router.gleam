import actors/matchmaker
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/json
import gleam/option
import mist.{type WebsocketConnection, type WebsocketMessage}
import wisp
import ws_custom.{type WebsocketCustom}

pub type TextRequest {
  TextRequest(method: String, payload: Dynamic)
}

pub type WebsocketState {
  WebsocketState(
    subject: Subject(WebsocketCustom),
    matchmaker_subject: Subject(matchmaker.Message),
  )
}

pub fn on_init(
  _conn: WebsocketConnection,
  matchmaker_subject: Subject(matchmaker.Message),
) {
  let subject = process.new_subject()

  #(
    WebsocketState(subject:, matchmaker_subject:),
    process.new_selector()
      |> process.select(subject)
      |> option.Some(),
  )
}

pub fn on_close(state: WebsocketState) -> Nil {
  process.send(state.matchmaker_subject, matchmaker.Exit(state.subject))
  Nil
}

pub fn handler(
  state: WebsocketState,
  message: WebsocketMessage(WebsocketCustom),
  conn: WebsocketConnection,
) {
  case message {
    mist.Text(text) -> text_handler(state, conn, text)
    mist.Binary(binary) -> binary_handler(state, conn, binary)
    mist.Custom(custom) -> custom_handler(state, conn, custom)
    mist.Closed | mist.Shutdown -> mist.stop()
  }
}

fn text_handler(
  state: WebsocketState,
  conn: WebsocketConnection,
  text: String,
) {
  let text_request_decoder = {
    use method <- decode.field("method", decode.string)
    use payload <- decode.field("payload", decode.dynamic)
    decode.success(TextRequest(method:, payload:))
  }

  case json.parse(from: text, using: text_request_decoder) {
    Ok(TextRequest(method: method, payload: payload)) -> {
      text_request_handler(state, conn, method, payload)
    }

    Error(_) -> {
      let assert Ok(_) = mist.send_text_frame(conn, "parse error")
      mist.continue(state)
    }
  }
}

fn text_request_handler(
  state: WebsocketState,
  conn: WebsocketConnection,
  method: String,
  _payload: Dynamic,
) {
  case method {
    "ping" -> {
      let assert Ok(_) = mist.send_text_frame(conn, "pong")
      mist.continue(state)
    }

    "enter_matchmaking" -> {
      process.send(state.matchmaker_subject, matchmaker.Enter(state.subject))
      mist.continue(state)
    }

    "exit_matchmaking" -> {
      process.send(state.matchmaker_subject, matchmaker.Exit(state.subject))
      mist.continue(state)
    }

    _ -> {
      // TODO
      let assert Ok(_) =
        mist.send_text_frame(conn, "method not found: " <> method)
      mist.continue(state)
    }
  }
}

fn binary_handler(
  state: WebsocketState,
  _conn: WebsocketConnection,
  _binary: BitArray,
) {
  wisp.log_info("Received binary frame")
  mist.continue(state)
}

fn custom_handler(
  state: WebsocketState,
  conn: WebsocketConnection,
  custom: WebsocketCustom,
) {
  case custom {
    ws_custom.Broadcast(text) -> {
      let assert Ok(_) = mist.send_text_frame(conn, text)
      mist.continue(state)
    }

    ws_custom.Matched -> {
      let assert Ok(_) = mist.send_text_frame(conn, "matched")
      mist.continue(state)
    }
  }
}
