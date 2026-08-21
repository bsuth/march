import lustre/effect
import lustre/element
import main/app.{type App}
import main/message as main_message
import main/model as main_model
import routes/match/init
import routes/match/message.{type Message as RouteMessage}
import routes/match/model.{type Model as RouteModel, Model as RouteModel}
import routes/match/update
import routes/match/update_ws
import routes/match/view
import ws_api

pub fn init(app: App, id: String) {
  let #(route_model, route_effect) = init.init(app, id)
  #(main_model.Match(route_model), effect.map(route_effect, main_message.Match))
}

pub fn deinit(route_model: RouteModel) {
  init.deinit(route_model)
}

pub fn update(route_model: RouteModel, route_message: RouteMessage) {
  let #(route_model, route_effect) = update.update(route_model, route_message)
  #(main_model.Match(route_model), effect.map(route_effect, main_message.Match))
}

pub fn update_ws(route_model: RouteModel, ws_message: ws_api.Message) {
  let #(route_model, route_effect) =
    update_ws.update_ws(route_model, ws_message)
  #(main_model.Match(route_model), effect.map(route_effect, main_message.Match))
}

pub fn update_app(route_model: RouteModel, app: App) {
  RouteModel(..route_model, app:)
}

pub fn view(route_model: RouteModel) {
  element.map(view.view(route_model), main_message.Match)
}
