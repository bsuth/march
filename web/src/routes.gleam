import gleam/uri.{type Uri}
import lustre/attribute.{type Attribute}
import lustre/effect
import main/message.{type Message}
import main/model.{type Model}
import routes/about
import routes/home
import routes/learn
import routes/lobby
import routes/match
import routes/not_found

pub fn init(model: Model, uri: Uri) {
  let app = model.get_app(model)

  case model {
    model.Home(route) -> home.deinit(route)
    model.Learn(route) -> learn.deinit(route)
    model.Lobby(route) -> lobby.deinit(route)
    model.Match(route) -> match.deinit(route)
    _ -> Nil
  }

  case uri.path_segments(uri.path) {
    [] -> home.init(app)
    ["about"] -> #(model.About(app), effect.none())
    ["learn"] -> learn.init(app)
    ["lobby", id] -> lobby.init(app, id)
    ["match", id] -> match.init(app, id)
    _ -> #(model.Model(app), effect.none())
  }
}

pub fn view(model: Model, attrs: List(Attribute(Message))) {
  case model {
    model.About(_) -> about.view(attrs)
    model.Home(route) -> home.view(route)
    model.Learn(route) -> learn.view(route)
    model.Lobby(route) -> lobby.view(route)
    model.Match(route) -> match.view(route)
    _ -> not_found.view(attrs)
  }
}
