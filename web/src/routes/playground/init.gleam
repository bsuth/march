import core/engine
import core/engine/settings
import lustre/effect
import main/app.{type App}
import routes/playground/model.{type Model, Model}

pub fn init(app: App) {
  let engine_settings = settings.standard()
  let engine_kernel = engine.new_kernel(engine_settings)
  let engine = engine.new(engine_kernel)

  #(Model(app:, engine:), effect.none())
}

pub fn deinit(_model: Model) {
  Nil
}
