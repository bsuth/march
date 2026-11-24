import core/engine
import core/engine/settings as engine_settings
import core/engine/turn
import gleam/option
import gleam/result
import lustre/effect
import main/app.{type App}
import modem
import routes/learn_classic/chapter
import routes/learn_classic/model.{type Model, Model}

pub fn init(app: App, chapter_string: String) {
  let parsed_chapter = chapter.from_string(chapter_string)

  let engine = case parsed_chapter {
    Ok(chapter) -> chapter.engine(chapter)
    _ ->
      engine_settings.classic()
      |> engine.new_kernel()
      |> engine.new()
  }

  #(
    Model(
      app:,
      chapter: result.unwrap(parsed_chapter, chapter.Introduction),
      engine:,
      show_table_of_contents: False,
      turn_request: turn.Request(option.None, [], option.None),
      turn_request_engine: engine,
    ),
    case result.is_error(parsed_chapter) {
      True ->
        modem.replace(
          chapter.url(chapter.Introduction),
          option.None,
          option.None,
        )
      False -> effect.none()
    },
  )
}

pub fn deinit(_model: Model) {
  Nil
}
