import lustre/effect
import lustre/element
import main/app.{type App}
import main/message as main_message
import main/model as main_model
import routes/learn/init
import routes/learn/message.{type Message as RouteMessage}
import routes/learn/model.{type Model as RouteModel}
import routes/learn/update
import routes/learn/view

pub fn init(app: App) {
  let #(route_model, route_effect) = init.init(app)

  #(
    main_model.Learn(route_model.app, route_model),
    effect.map(route_effect, main_message.Learn),
  )
}

pub fn update(route_model: RouteModel, route_message: RouteMessage) {
  let #(route_model, route_effect) = update.update(route_model, route_message)

  #(
    main_model.Learn(route_model.app, route_model),
    effect.map(route_effect, main_message.Learn),
  )
}

pub fn view(route_model: RouteModel) {
  element.map(view.view(route_model), main_message.Learn)
}
