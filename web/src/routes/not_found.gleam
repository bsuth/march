import lustre/attribute.{type Attribute}
import lustre/element/html

pub fn view(attrs: List(Attribute(msg))) {
  html.div([attribute.class("p-4"), ..attrs], [
    html.text("Not Found"),
  ])
}
