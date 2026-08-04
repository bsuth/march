import gleam/erlang/process.{type Subject}
import ipc
import names.{type Names}

pub type WebsocketState {
  WebsocketState(user_id: String, names: Names, subject: Subject(ipc.Websocket))
}
