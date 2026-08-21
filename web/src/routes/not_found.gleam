import lustre/attribute.{type Attribute}
import lustre/element/html
import main/message.{type Message}
import phosphor

pub fn view(attrs: List(Attribute(Message))) {
  html.div(
    [
      attribute.class("h-full"),
      attribute.class("flex flex-col items-center justify-center gap-4"),
      ..attrs
    ],
    [
      phosphor.empty_regular([attribute.class("size-12")]),
      html.text("Page Not Found"),
    ],
  )
}
