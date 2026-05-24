import gleam/dynamic/decode
import gleam/json

pub type Session {
  Session(name: String)
}

pub fn decoder() {
  use name <- decode.field("name", decode.string)
  decode.success(Session(name:))
}

pub fn json(session: Session) {
  json.object([#("name", json.string(session.name))])
}
