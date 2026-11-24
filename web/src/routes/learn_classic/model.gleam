import core/engine.{type Engine}
import core/engine/turn
import main/app.{type App}
import routes/learn_classic/chapter.{type Chapter}

pub type Model {
  Model(
    app: App,
    chapter: Chapter,
    engine: Engine,
    show_table_of_contents: Bool,
    turn_request: turn.Request,
    turn_request_engine: Engine,
  )
}
