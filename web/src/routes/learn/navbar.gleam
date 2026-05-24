import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor
import routes/learn/x.{type Model, type Msg}

fn navbar_button(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.button(
    [
      attribute.class(
        "cursor-pointer flex gap-2 px-4 py-2 items-center rounded",
      ),
      attribute.class("disabled:opacity-50 disabled:cursor-not-allowed"),
      attribute.class("not-disabled:hover:bg-gray-900"),
      ..attrs
    ],
    children,
  )
}

pub fn view(model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.div([attribute.class("flex gap-8 justify-center"), ..attrs], [
    navbar_button(
      [
        attribute.disabled(model.chapter_index == 0),
        event.on_click(x.PrevChapter),
      ],
      [
        phosphor.arrow_circle_left_regular([attribute.class("w-6 h-6")]),
        html.text("Prev"),
      ],
    ),
    navbar_button(
      [
        event.on_click(x.UserClickedTableOfContents),
      ],
      [
        phosphor.list_bullets_regular([
          attribute.class("w-6 h-6"),
          case model.show_table_of_contents {
            True -> attribute.class("text-blue-400")
            False -> attribute.none()
          },
        ]),
      ],
    ),
    navbar_button(
      [
        attribute.disabled(model.chapter_index > model.num_chapters - 2),
        event.on_click(x.NextChapter),
      ],
      [
        html.text("Next"),
        phosphor.arrow_circle_right_regular([attribute.class("w-6 h-6")]),
      ],
    ),
  ])
}
