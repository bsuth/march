import lustre/attribute
import lustre/element/html
import phosphor

pub fn view() {
  html.div(
    [
      attribute.class("h-full"),
      attribute.class("flex flex-col items-center justify-center gap-4"),
    ],
    [
      phosphor.empty_regular([attribute.class("size-12")]),
      html.text("Page Not Found"),
    ],
  )
}
