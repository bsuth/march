import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}

pub type Message {
  Message(path: String, payload: Dynamic)
}

pub fn json(path: String, payload: Json) {
  json.object([
    #("path", json.string(path)),
    #("payload", payload),
  ])
}

pub fn decoder() {
  use path <- decode.field("path", decode.string)
  use payload <- decode.field("payload", decode.dynamic)
  decode.success(Message(path:, payload:))
}
