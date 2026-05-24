import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/x.{type Model, type Msg}

pub const title = "Conclusion"

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.section(attrs, [
    html.h2([], [html.text(title)]),
    html.text(
      "That's it! In total, March is a very minimal and simple game that offers
      a good amount of strategic depth. Be sure to check out the cheatsheet if
      you forget anything!",
    ),
  ])
}
