import gleam/list
import gleam/result
import lustre/attribute
import lustre/element/html
import routes/learn/lib/chapter
import routes/learn/model.{type Model}
import routes/learn/view/chapter_capturing_cards
import routes/learn/view/chapter_conclusion
import routes/learn/view/chapter_gameplay
import routes/learn/view/chapter_moving_cards
import routes/learn/view/chapter_not_found
import routes/learn/view/chapter_setup
import routes/learn/view/navbar
import routes/learn/view/table_of_contents

pub fn view(model: Model) {
  let chapter =
    chapter.order
    |> list.drop(model.chapter_index)
    |> list.first()
    |> result.unwrap(chapter.NotFound)

  html.div(
    [
      attribute.class("max-w-4xl h-full m-auto p-4"),
      attribute.class("flex flex-col gap-4"),
      attribute.class("overflow-auto"),
    ],
    [
      case model.show_table_of_contents, chapter {
        True, _ -> table_of_contents.view(model, [attribute.class("grow")])

        _, chapter.Setup -> chapter_setup.view(model, [attribute.class("grow")])

        _, chapter.Gameplay ->
          chapter_gameplay.view(model, [attribute.class("grow")])

        _, chapter.MovingCards ->
          chapter_moving_cards.view(model, [attribute.class("grow")])

        _, chapter.CapturingCards ->
          chapter_capturing_cards.view(model, [attribute.class("grow")])

        _, chapter.Conclusion ->
          chapter_conclusion.view(model, [attribute.class("grow")])

        _, _ -> chapter_not_found.view(model, [attribute.class("grow")])
      },
      navbar.view(model, []),
    ],
  )
}
