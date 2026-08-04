import gleam/result
import gleam/uri
import http_api/http_init
import lib/websocket
import lustre/effect
import main/app.{App}
import main/message
import main/model.{Model}
import modem
import routes
import rsvp

pub fn init(_) {
  let uri = modem.initial_uri() |> result.unwrap(uri.empty)

  let #(ws, ws_effect) =
    websocket.init(
      // TODO: Read this from env variables.
      // In particular, needs to be different when running inside docker.
      "ws://localhost:8000/ws",
      fn() { message.WebsocketOpen },
      fn(msg) { message.WebsocketMessage(msg) },
      fn() { message.WebsocketClose },
      fn() { message.WebsocketError },
    )

  let #(model, routes_effect) = routes.init(Model(App(user_id: "", ws:)), uri)

  #(
    model,
    effect.batch([
      modem.init(message.RouterChangedUri),
      ws_effect,
      routes_effect,
      http_init.get_response_decoder()
        |> rsvp.expect_json(message.ApiInitGetResponse)
        |> rsvp.get("/api/init", _),
    ]),
  )
}
