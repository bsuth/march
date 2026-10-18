import core/engine.{type Engine}
import main/app.{type App}

pub type Model {
  Model(app: App, engine: Engine)
}
