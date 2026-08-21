import gleam/dynamic.{type Dynamic}
import lustre/effect
import routes/home/model.{type Model}
import ws_api

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    "lobbies.update" -> lobbies_update(model, ws_message.payload)
    _ -> #(model, effect.none())
  }
}

fn lobbies_update(model: Model, _payload: Dynamic) {
  #(model, effect.none())
}
