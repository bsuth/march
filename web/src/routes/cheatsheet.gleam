import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import x.{type Model, type Msg}

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.div([attribute.class("p-4"), ..attrs], [
    html.text("cheat sheet page"),
  ])
}
