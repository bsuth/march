import lustre/effect
import routes/learn/model.{type Model}
import ws_api

pub fn update_ws(model: Model, _ws_message: ws_api.Message) {
  #(model, effect.none())
}
