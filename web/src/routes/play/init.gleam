import lustre/effect
import main/app.{type App}
import routes/play/model.{type Model, Model}

pub fn init(app: App) {
  #(Model(app:), effect.none())
}

pub fn deinit(_model: Model) {
  Nil
}
