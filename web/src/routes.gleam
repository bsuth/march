import gleam/uri.{type Uri}
import lustre/attribute.{type Attribute}
import lustre/effect
import main/message.{type Message}
import main/model.{type Model}
import routes/about
import routes/home
import routes/learn
import routes/lobby
import routes/not_found
import routes/versus

// TODO: remove versus as component
pub fn register() {
  let assert Ok(_) = versus.register()
}

pub fn init(model: Model, uri: Uri) {
  let app = model.get_app(model)

  case uri.path_segments(uri.path) {
    [] -> home.init(app)
    ["about"] -> #(model.About(app), effect.none())
    ["learn"] -> learn.init(app)
    ["lobby", id] -> lobby.init(app, id)
    ["versus"] -> #(model.Versus(app), effect.none())
    _ -> #(model, effect.none())
  }
}

pub fn view(model: Model, attrs: List(Attribute(Message))) {
  case model {
    model.About(_) -> about.view(attrs)
    model.Home(route) -> home.view(route)
    model.Learn(route) -> learn.view(route)
    model.Lobby(route) -> lobby.view(route)
    model.Versus(_) -> versus.element(attrs)
    _ -> not_found.view(attrs)
  }
}
