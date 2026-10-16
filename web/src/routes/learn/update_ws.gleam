import core/ws_api
import lustre/effect
import routes/learn/model.{type Model}

pub fn update_ws(model: Model, _ws_message: ws_api.Message) {
  #(model, effect.none())
}
