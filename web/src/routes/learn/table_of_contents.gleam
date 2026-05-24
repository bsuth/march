import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor
import routes/learn/chapter
import routes/learn/x.{type Model, type Msg}

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.div(
    [
      attribute.class("flex flex-col gap-4 items-center justify-center"),
      ..attrs
    ],
    [
      html.h3([], [html.text("Table of Contents")]),
      html.ul(
        [attribute.class("flex flex-col items-center")],
        list.index_map(chapter.chapters, fn(chapter_title_view, chapter_index) {
          html.li(
            [
              // TODO: show active chapter
              attribute.class(
                "cursor-pointer px-2 py-2 flex gap-2 items-center hover:text-blue-400",
              ),
              event.on_click(x.UserClickedTableOfContentsChapter(chapter_index)),
            ],
            [
              case chapter_index % 4 {
                3 -> phosphor.heart_fill([attribute.class("w-3 h-3")])
                2 -> phosphor.club_fill([attribute.class("w-3 h-3")])
                1 -> phosphor.diamond_fill([attribute.class("w-3 h-3")])
                _ -> phosphor.spade_fill([attribute.class("w-3 h-3")])
              },
              html.text(chapter_title_view.0),
              case chapter_index % 4 {
                3 -> phosphor.heart_fill([attribute.class("w-3 h-3")])
                2 -> phosphor.club_fill([attribute.class("w-3 h-3")])
                1 -> phosphor.diamond_fill([attribute.class("w-3 h-3")])
                _ -> phosphor.spade_fill([attribute.class("w-3 h-3")])
              },
            ],
          )
        }),
      ),
    ],
  )
}
