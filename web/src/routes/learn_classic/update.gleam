import lustre/effect
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model, Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.JumpToChapter(chapter_index) ->
      jump_to_chapter(model, chapter_index)
    message.PreviousChapter -> previous_chapter(model)
    message.NextChapter -> next_chapter(model)
    message.ToggleTableOfContents -> toggle_table_of_contents(model)
  }
}

fn jump_to_chapter(model: Model, chapter_index: Int) {
  #(Model(..model, chapter_index:), effect.none())
}

fn previous_chapter(model: Model) {
  #(Model(..model, chapter_index: model.chapter_index - 1), effect.none())
}

fn next_chapter(model: Model) {
  #(Model(..model, chapter_index: model.chapter_index + 1), effect.none())
}

fn toggle_table_of_contents(model: Model) {
  #(
    Model(..model, show_table_of_contents: !model.show_table_of_contents),
    effect.none(),
  )
}
