import core/engine/position.{type Position}
import core/engine/settings.{type Settings as EngineSettings}
import gleam/option.{type Option}
import main/app.{type App}
import routes/learn_classic/chapter.{type Chapter}

pub type Model {
  Model(
    app: App,
    board_hover_index: Option(Int),
    board_position: Position,
    chapter: Chapter,
    engine_settings: EngineSettings,
    show_table_of_contents: Bool,
  )
}
