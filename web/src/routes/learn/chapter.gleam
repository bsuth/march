import gleam/list
import gleam/result
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import routes/learn/chapter_capturing_cards
import routes/learn/chapter_conclusion
import routes/learn/chapter_gameplay
import routes/learn/chapter_moving_cards
import routes/learn/chapter_not_found
import routes/learn/chapter_setup
import routes/learn/x.{type Model, type Msg}

const default_chapter = #(chapter_not_found.title, chapter_not_found.view)

pub const chapters = [
  #(chapter_setup.title, chapter_setup.view),
  #(chapter_gameplay.title, chapter_gameplay.view),
  #(chapter_moving_cards.title, chapter_moving_cards.view),
  #(chapter_capturing_cards.title, chapter_capturing_cards.view),
  #(chapter_conclusion.title, chapter_conclusion.view),
]

pub fn view(model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  let chapter =
    chapters
    |> list.drop(model.chapter_index)
    |> list.first()
    |> result.unwrap(default_chapter)

  chapter.1(model, attrs)
}
