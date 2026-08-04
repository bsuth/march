import gleam/json
import lustre/effect
import main/model.{type Model}
import routes/home
import routes/learn
import routes/lobby
import ws_api
import yuzu

pub fn update_ws(model: Model, message: String) {
  // TODO: log on unknown error
  use ws_message <- yuzu.ok(json.parse(message, ws_api.decoder()), #(
    model,
    effect.none(),
  ))

  case model {
    model.Home(route_model) -> home.update_ws(route_model, ws_message)
    model.Learn(route_model) -> learn.update_ws(route_model, ws_message)
    model.Lobby(route_model) -> lobby.update_ws(route_model, ws_message)
    _ -> #(model, effect.none())
  }
}
