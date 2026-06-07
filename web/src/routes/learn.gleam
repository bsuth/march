import gleam/int
import gleam/list
import lustre
import lustre/attribute.{type Attribute}
import lustre/effect
import lustre/element
import lustre/element/html
import routes/learn/chapter
import routes/learn/navbar
import routes/learn/table_of_contents
import routes/learn/x.{type Model, type Msg}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-learn"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [])
  |> lustre.register(element_name)
}

fn init(_) {
  let num_chapters = list.length(chapter.chapters)

  #(
    x.Model(
      chapter_index: 0,
      num_chapters: num_chapters,
      show_table_of_contents: False,
    ),
    effect.none(),
  )
}

fn update(model: Model, msg: Msg) {
  case msg {
    x.PrevChapter -> #(
      x.Model(
        ..model,
        chapter_index: int.max(0, model.chapter_index - 1),
        show_table_of_contents: False,
      ),
      effect.none(),
    )

    x.NextChapter -> #(
      x.Model(
        ..model,
        chapter_index: int.min(model.num_chapters, model.chapter_index + 1),
        show_table_of_contents: False,
      ),
      effect.none(),
    )

    x.UserClickedTableOfContents -> #(
      x.Model(..model, show_table_of_contents: !model.show_table_of_contents),
      effect.none(),
    )

    x.UserClickedTableOfContentsChapter(new_chapter_index) -> #(
      x.Model(
        ..model,
        chapter_index: new_chapter_index,
        show_table_of_contents: False,
      ),
      effect.none(),
    )
  }
}

fn view(model: Model) {
  html.div(
    [
      attribute.class(
        "flex h-full flex-col gap-4 m-auto max-w-4xl overflow-auto p-4",
      ),
    ],
    [
      case model.show_table_of_contents {
        True -> table_of_contents.view(model, [attribute.class("grow")])
        False -> chapter.view(model, [attribute.class("grow")])
      },
      navbar.view(model, []),
    ],
  )
}
