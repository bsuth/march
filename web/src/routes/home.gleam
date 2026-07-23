import lustre/effect
import lustre/element
import main/app.{type App}
import main/message as main_message
import main/model as main_model
import routes/home/init
import routes/home/message.{type Message as RouteMessage}
import routes/home/model.{type Model as RouteModel}
import routes/home/update
import routes/home/view

pub fn init(app: App) {
  let #(route_model, route_effect) = init.init(app)

  #(
    main_model.Home(route_model.app, route_model),
    effect.map(route_effect, main_message.Home),
  )
}

pub fn update(route_model: RouteModel, route_message: RouteMessage) {
  let #(route_model, route_effect) = update.update(route_model, route_message)

  #(
    main_model.Home(route_model.app, route_model),
    effect.map(route_effect, main_message.Home),
  )
}

pub fn view(route_model: RouteModel) {
  element.map(view.view(route_model), main_message.Home)
}
