import core/ws_api
import lustre/effect
import routes/match/model.{type Model}

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    _ -> #(model, effect.none())
  }
}
