import gleam/uri.{type Uri}
import lustre/effect
import main/model.{type Model}
import routes/about
import routes/home
import routes/learn
import routes/learn_classic
import routes/lobby
import routes/match
import routes/not_found
import routes/play
import routes/playground

pub fn init(model: Model, uri: Uri) {
  let app = model.get_app(model)

  case model {
    model.Home(route) -> home.deinit(route)
    model.Learn(route) -> learn.deinit(route)
    model.LearnClassic(route) -> learn_classic.deinit(route)
    model.Lobby(route) -> lobby.deinit(route)
    model.Match(route) -> match.deinit(route)
    model.Play(route) -> play.deinit(route)
    model.Playground(route) -> playground.deinit(route)
    _ -> Nil
  }

  case uri.path_segments(uri.path) {
    [] -> home.init(app)
    ["about"] -> #(model.About(app), effect.none())
    ["learn"] -> learn.init(app)
    ["learn", "classic"] -> learn_classic.init(app)
    ["lobby", id] -> lobby.init(app, id)
    ["match", id] -> match.init(app, id)
    ["play"] -> play.init(app)
    ["playground"] -> playground.init(app)
    _ -> #(model.Model(app), effect.none())
  }
}

pub fn view(model: Model) {
  case model {
    model.About(_) -> about.view()
    model.Home(route) -> home.view(route)
    model.Learn(route) -> learn.view(route)
    model.LearnClassic(route) -> learn_classic.view(route)
    model.Lobby(route) -> lobby.view(route)
    model.Match(route) -> match.view(route)
    model.Play(route) -> play.view(route)
    model.Playground(route) -> playground.view(route)
    _ -> not_found.view()
  }
}
