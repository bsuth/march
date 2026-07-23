import lustre/attribute.{type Attribute}
import lustre/element/html
import main/message.{type Message}

pub fn view(attrs: List(Attribute(Message))) {
  html.div([attribute.class("p-4"), ..attrs], [
    html.text("Not Found"),
  ])
}
