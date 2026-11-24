import components/button
import lustre/attribute
import lustre/element/html
import routes/learn/model.{type Model}

pub fn view(_model: Model) {
  html.div(
    [
      attribute.class("w-full h-full max-w-4xl m-auto p-4"),
      attribute.class("flex flex-col gap-4"),
      attribute.class("overflow-auto"),
    ],
    [
      html.a(
        [
          attribute.class("w-full p-4"),
          attribute.class("flex justify-between items-center gap-2"),
          attribute.class("border"),
          attribute.href("/learn/classic"),
        ],
        [
          html.div([], [
            html.h5([], [html.text("Classic")]),
            html.text("The recommended way to learn March."),
          ]),
          button.element([], [
            html.text("Tutorial"),
          ]),
        ],
      ),
      html.a(
        [
          attribute.class("w-full p-4"),
          attribute.class("flex justify-between items-center gap-2"),
          attribute.class("border"),
          attribute.href("/learn/standard"),
        ],
        [
          html.div([], [
            html.h5([], [html.text("Standard")]),
            html.text("The competitive way to learn March."),
          ]),
          button.element([], [
            html.text("Tutorial"),
          ]),
        ],
      ),
      html.a(
        [
          attribute.class("w-full p-4"),
          attribute.class("flex justify-between items-center gap-2"),
          attribute.class("border"),
          attribute.href("/learn/doubles"),
        ],
        [
          html.div([], [
            html.h5([], [html.text("Doubles")]),
            html.text("Team-based 2v2 play."),
          ]),
          button.element([], [
            html.text("Tutorial"),
          ]),
        ],
      ),
    ],
  )
}
