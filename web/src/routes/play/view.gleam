import lustre/attribute.{type Attribute}
import lustre/element/html
import routes/play/message.{type Message}
import routes/play/model.{type Model}

pub fn view(_model: Model) {
  html.div([attribute.class("py-16 flex flex-col gap-16")], [
    html.section([attribute.class("flex flex-col items-center gap-4")], [
      html.div(
        [attribute.class("w-full flex justify-center items-center gap-4")],
        [
          html.hr([attribute.class("w-1/5 opacity-40")]),
          html.text("Quick Play"),
          html.hr([attribute.class("w-1/5 opacity-40")]),
        ],
      ),
      html.div([attribute.class("grid grid-cols-2 gap-4")], [
        game_view("Classic", []),
        game_view("Standard", []),
        game_view("Doubles", []),
        game_view("Custom", [
          // event.on_click(message.SubmitLobbyPostRequest),
        // button.prop_loading(model.post_lobby_request_loading),
        ]),
      ]),
    ]),
  ])
}

fn game_view(title: String, attrs: List(Attribute(Message))) {
  html.div(
    [
      attribute.class("w-32 h-32"),
      attribute.class("flex justify-center items-center"),
      attribute.class("text-(--march-50) bg-(--march-800)"),
      attribute.class("hover:text-(--march-950) hover:bg-(--march-200)"),
      attribute.class("cursor-pointer"),
      ..attrs
    ],
    [html.div([], [html.text(title)])],
  )
}
