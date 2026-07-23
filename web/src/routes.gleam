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
  case uri.path_segments(uri.path) {
    [] -> home.init(model.app)
    ["about"] -> #(model.About(model.app), effect.none())
    ["learn"] -> learn.init(model.app)
    ["lobby", _] -> lobby.init(model.app)
    ["versus"] -> #(model.Versus(model.app), effect.none())
    _ -> #(model, effect.none())
  }
}

pub fn view(model: Model, attrs: List(Attribute(Message))) {
  case model {
    model.About(_) -> about.view(attrs)
    model.Home(_, route) -> home.view(route)
    model.Learn(_, route) -> learn.view(route)
    model.Lobby(_, route) -> lobby.view(route)
    model.Versus(_) -> versus.element(attrs)
    _ -> not_found.view(attrs)
  }
}
