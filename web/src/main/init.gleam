import api
import gleam/option
import gleam/result
import gleam/uri
import lustre/effect
import main/app.{App}
import main/message
import main/model.{Model}
import modem
import routes
import rsvp

pub fn init(_) {
  let uri = modem.initial_uri() |> result.unwrap(uri.empty)
  let #(model, routes_effect) = routes.init(Model(App(ws: option.None)), uri)

  #(
    model,
    effect.batch([
      modem.init(message.RouterChangedUri),
      routes_effect,
      api.get_init_response_decoder()
        |> rsvp.expect_json(message.ApiReturnedInit)
        |> rsvp.get("/api/init", _),
    ]),
  )
}
