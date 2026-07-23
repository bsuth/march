import lustre/effect
import lustre/element
import main/app.{type App}
import main/message as main_message
import main/model as main_model
import routes/lobby/init
import routes/lobby/message.{type Message as RouteMessage}
import routes/lobby/model.{type Model as RouteModel}
import routes/lobby/update
import routes/lobby/view

pub fn init(app: App) {
  let #(route_model, route_effect) = init.init(app)

  #(
    main_model.Lobby(route_model.app, route_model),
    effect.map(route_effect, main_message.Lobby),
  )
}

pub fn update(route_model: RouteModel, route_message: RouteMessage) {
  let #(route_model, route_effect) = update.update(route_model, route_message)

  #(
    main_model.Lobby(route_model.app, route_model),
    effect.map(route_effect, main_message.Lobby),
  )
}

pub fn view(route_model: RouteModel) {
  element.map(view.view(route_model), main_message.Lobby)
}
