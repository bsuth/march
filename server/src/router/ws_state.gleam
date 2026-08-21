import core/user.{type User}
import gleam/erlang/process.{type Subject}
import ipc
import names.{type Names}

pub type WebsocketState {
  WebsocketState(names: Names, user: User, subject: Subject(ipc.Websocket))
}
