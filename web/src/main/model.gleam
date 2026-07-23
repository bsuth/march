import main/app.{type App}
import routes/home/model as home
import routes/learn/model as learn
import routes/lobby/model as lobby

pub type Model {
  Model(app: App)
  About(app: App)
  Home(app: App, route: home.Model)
  Learn(app: App, route: learn.Model)
  Lobby(app: App, route: lobby.Model)
  Versus(app: App)
}
