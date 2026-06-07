import lustre/attribute.{type Attribute}
import lustre/element/html
import main/message.{type Message}
import main/model.{type Model}

pub fn view(_model: Model, attrs: List(Attribute(Message))) {
  html.div(
    [
      attribute.class(
        "flex h-full flex-col gap-4 m-auto max-w-4xl overflow-auto p-4",
      ),
      ..attrs
    ],
    [
      html.text("Lobby: "),
    ],
  )
}
