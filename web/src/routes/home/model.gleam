import core/engine.{type Engine}
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    hero_engine: Engine,
    hero_engine_timeout: Int,
    post_lobby_request_loading: Bool,
  )
}
