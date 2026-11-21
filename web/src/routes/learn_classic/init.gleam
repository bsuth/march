import gleam/option
import gleam/result
import lustre/effect
import main/app.{type App}
import modem
import routes/learn_classic/chapter
import routes/learn_classic/model.{type Model, Model}

pub fn init(app: App, chapter_string: String) {
  let parsed_chapter = chapter.from_string(chapter_string)

  #(
    Model(
      app:,
      chapter: result.unwrap(parsed_chapter, chapter.Introduction),
      show_table_of_contents: False,
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
