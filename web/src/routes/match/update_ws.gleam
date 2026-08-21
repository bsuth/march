import lustre/effect
import routes/match/model.{type Model}
import ws_api

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    _ -> #(model, effect.none())
  }
}
