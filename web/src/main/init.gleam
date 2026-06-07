import gleam/result
import gleam/uri
import lib/websocket
import lustre/effect
import main/message
import main/model.{Model}
import modem

pub fn init(_) {
  // TODO: get websocket url from env
  let ws = websocket.new("ws://localhost:8000/ws")

  #(
    Model(uri: modem.initial_uri() |> result.unwrap(uri.empty), ws:),
    effect.batch([
      modem.init(message.RouterChangedUri),
      websocket.on_message(ws, message.WebsocketMessage),
    ]),
  )
}
