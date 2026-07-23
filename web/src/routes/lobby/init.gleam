import lustre/effect
import main/app.{type App}
import routes/lobby/model.{Model}

pub fn init(app: App) {
  #(Model(app:), effect.none())
}
