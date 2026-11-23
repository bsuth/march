import core/engine/board.{Board}
import core/engine/face
import core/engine/position
import core/engine/position_card.{PositionCard}
import core/engine/settings as engine_settings
import core/engine/suit
import gleam/option
import gleam/result
import lustre/effect
import main/app.{type App}
import modem
import routes/learn_classic/chapter
import routes/learn_classic/model.{type Model, Model}

pub fn init(app: App, chapter_string: String) {
  let parsed_chapter = chapter.from_string(chapter_string)

  let board = Board(4, 4)

  let board_position = case parsed_chapter {
    Ok(chapter.Leading) ->
      board
      |> position.new()
      |> position.insert_one(#(
        0,
        option.Some(PositionCard(0, face.Jack, suit.Spades)),
      ))
    _ -> position.new(board)
  }

  #(
    Model(
      app:,
      board_position:,
      board_hover_index: option.None,
      chapter: result.unwrap(parsed_chapter, chapter.Introduction),
      engine_settings: engine_settings.classic(),
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
