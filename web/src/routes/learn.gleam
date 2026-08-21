import lustre/effect
import lustre/element
import main/app.{type App}
import main/message as main_message
import main/model as main_model
import routes/learn/init
import routes/learn/message.{type Message as RouteMessage}
import routes/learn/model.{type Model as RouteModel, Model as RouteModel}
import routes/learn/update
import routes/learn/update_ws
import routes/learn/view
import ws_api

pub fn init(app: App) {
  let #(route_model, route_effect) = init.init(app)
  #(main_model.Learn(route_model), effect.map(route_effect, main_message.Learn))
}

pub fn deinit(route_model: RouteModel) {
  init.deinit(route_model)
}

pub fn update(route_model: RouteModel, route_message: RouteMessage) {
  let #(route_model, route_effect) = update.update(route_model, route_message)
  #(main_model.Learn(route_model), effect.map(route_effect, main_message.Learn))
}

pub fn update_ws(route_model: RouteModel, ws_message: ws_api.Message) {
  let #(route_model, route_effect) =
    update_ws.update_ws(route_model, ws_message)
  #(main_model.Learn(route_model), effect.map(route_effect, main_message.Learn))
}

pub fn update_app(route_model: RouteModel, app: App) {
  RouteModel(..route_model, app:)
}

pub fn view(route_model: RouteModel) {
  element.map(view.view(route_model), main_message.Learn)
}
