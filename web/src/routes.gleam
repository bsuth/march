import gleam/uri
import lustre/attribute.{type Attribute}
import main/message.{type Message}
import main/model.{type Model}
import routes/about
import routes/home
import routes/learn
import routes/lobby
import routes/not_found
import routes/versus

pub fn register() {
  let assert Ok(_) = learn.register()
  let assert Ok(_) = versus.register()
}

pub fn view(model: Model, attrs: List(Attribute(Message))) {
  case uri.path_segments(model.uri.path) {
    [] -> home.view(attrs)
    ["about"] -> about.view(attrs)
    ["learn"] -> learn.element(attrs)
    ["lobby", _] -> lobby.view(model, attrs)
    ["versus"] -> versus.element(attrs)
    _ -> not_found.view(attrs)
  }
}
