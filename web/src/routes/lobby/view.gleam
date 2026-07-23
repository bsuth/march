import lustre/attribute
import lustre/element/html
import routes/lobby/model.{type Model}

pub fn view(_model: Model) {
  html.div(
    [
      attribute.class("max-w-4xl h-full m-auto p-4"),
      attribute.class("flex flex-col gap-4"),
      attribute.class("overflow-auto"),
    ],
    [
      html.text("Lobby: "),
    ],
  )
}
