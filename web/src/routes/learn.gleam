import gleam/int
import gleam/list
import lustre
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/chapter
import routes/learn/navbar
import routes/learn/table_of_contents
import routes/learn/x.{type Model, type Msg}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "routes-learn"

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, element_name)
}

pub fn element(attrs: List(Attribute(msg))) -> Element(msg) {
  element.element(element_name, attrs, [])
}

// -----------------------------------------------------------------------------
// Properties
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
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

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
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

fn view(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "flex h-full flex-col gap-4 m-auto max-w-4xl bg-gray-900 overflow-auto p-4",
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
