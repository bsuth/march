import lustre/effect
import routes/learn/message.{type Message}
import routes/learn/model.{type Model, Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.UserClickedTableOfContents -> user_clicked_table_of_contents(model)

    message.UserClickedTableOfContentsChapter(chapter_index) ->
      user_clicked_table_of_contents_chapter(model, chapter_index)

    message.UserNavigatedNextChapter -> user_navigated_next_chapter(model)

    message.UserNavigatedPreviousChapter ->
      user_navigated_previous_chapter(model)
  }
}

fn user_clicked_table_of_contents(model: Model) {
  #(
    Model(..model, show_table_of_contents: !model.show_table_of_contents),
    effect.none(),
  )
}

fn user_clicked_table_of_contents_chapter(model: Model, chapter_index: Int) {
  #(
    Model(..model, chapter_index:, show_table_of_contents: False),
    effect.none(),
  )
}

fn user_navigated_next_chapter(model: Model) {
  #(
    Model(
      ..model,
      chapter_index: model.chapter_index + 1,
      show_table_of_contents: False,
    ),
    effect.none(),
  )
}

fn user_navigated_previous_chapter(model: Model) {
  #(
    Model(
      ..model,
      chapter_index: model.chapter_index - 1,
      show_table_of_contents: False,
    ),
    effect.none(),
  )
}
