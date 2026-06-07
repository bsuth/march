import components/button
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import main/message.{type Message}
import phosphor

pub fn view(attrs: List(Attribute(Message))) {
  html.div(
    [attribute.class("max-w-xl m-auto"), attribute.class("flex gap-4"), ..attrs],
    [
      button.element([event.on_click(message.UserCreatedLobby)], [
        html.text("CREATE LOBBY"),
      ]),
      card_link_view(
        "Modern",
        "Cards have unique moves.",
        "./learn",
        phosphor.building_fill,
      ),
      card_link_view(
        "Classic",
        "Every card moves the same.",
        "./versus",
        phosphor.castle_turret_fill,
      ),
    ],
  )
}

fn card_link_view(
  title: String,
  description: String,
  href: String,
  icon: fn(List(Attribute(a))) -> Element(a),
) {
  html.a(
    [
      attribute.class("flex-1 p-4 flex flex-col gap-2"),
      attribute.class("rounded bg-(--bg-1)"),
      attribute.class("border-4 border-(--fg)"),
      attribute.class("hover:bg-(--bg-2)"),
      attribute.class("cursor-pointer"),
      attribute.href(href),
    ],
    [
      html.div([attribute.class("flex flex-col justify-between items-center")], [
        html.div([attribute.class("w-16 h-16 mb-2 relative")], [
          icon([
            attribute.class("w-16 h-16"),
            attribute.class("absolute top-1/2 left-1/2 -translate-1/2"),
          ]),
        ]),
        html.h3([attribute.class("flex items-center gap-2")], [
          html.text(title),
        ]),
        html.p([attribute.class("text-center")], [html.text(description)]),
      ]),
    ],
  )
}
