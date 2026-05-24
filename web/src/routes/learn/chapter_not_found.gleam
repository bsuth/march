import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/x.{type Model, type Msg}

pub const title = "Not Found"

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.section(attrs, [
    html.h2([], [html.text(title)]),
    html.text("You found an impossible chapter! But how?..."),
  ])
}
