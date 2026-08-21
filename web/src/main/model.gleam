import main/app.{type App}
import routes/home/model as home
import routes/learn/model as learn
import routes/lobby/model as lobby
import routes/match/model as match

pub type Model {
  Model(App)
  About(App)
  Home(home.Model)
  Learn(learn.Model)
  Lobby(lobby.Model)
  Match(match.Model)
}

pub fn get_app(model: Model) {
  case model {
    Model(app) -> app
    About(app) -> app
    Home(route) -> route.app
    Learn(route) -> route.app
    Lobby(route) -> route.app
    Match(route) -> route.app
  }
}
