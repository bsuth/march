import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import x.{type Model, type Msg}

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.div(
    [
      attribute.class("h-full p-4"),
      attribute.class("flex items-center justify-center gap-2"),
      ..attrs
    ],
    [
      html.button(
        [
          attribute.class("cursor-pointer p-4 rounded border"),
          event.on_click(x.UserClickedTest),
        ],
        [
          html.text("Matchmaking"),
        ],
      ),
    ],
  )
}
