import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element/html
import lustre/event
import phosphor
import routes/learn/lib/chapter
import routes/learn/message.{type Message}
import routes/learn/model.{type Model}

pub fn view(_model: Model, attrs: List(Attribute(Message))) {
  html.div(
    [
      attribute.class("flex flex-col gap-4 items-center justify-center"),
      ..attrs
    ],
    [
      html.h3([], [html.text("Table of Contents")]),
      html.ul(
        [attribute.class("flex flex-col items-center")],
        list.index_map(chapter.order, fn(chapter, index) {
          html.li(
            [
              // TODO: show active chapter
              attribute.class(
                "cursor-pointer px-2 py-2 flex gap-2 items-center hover:text-blue-400",
              ),
              index
                |> message.UserClickedTableOfContentsChapter()
                |> event.on_click(),
            ],
            [
              case index % 4 {
                3 -> phosphor.heart_fill([attribute.class("size-3")])
                2 -> phosphor.club_fill([attribute.class("size-3")])
                1 -> phosphor.diamond_fill([attribute.class("size-3")])
                _ -> phosphor.spade_fill([attribute.class("size-3")])
              },
              html.text(chapter.get_title(chapter)),
              case index % 4 {
                3 -> phosphor.heart_fill([attribute.class("size-3")])
                2 -> phosphor.club_fill([attribute.class("size-3")])
                1 -> phosphor.diamond_fill([attribute.class("size-3")])
                _ -> phosphor.spade_fill([attribute.class("size-3")])
              },
            ],
          )
        }),
      ),
    ],
  )
}
