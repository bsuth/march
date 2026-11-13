import components/button
import lustre/attribute
import lustre/element/html
import lustre/event
import routes/home/message
import routes/home/model.{type Model}

pub fn create_lobby_view(model: Model) {
  html.div([attribute.class("w-48 flex flex-col gap-4")], [
    button.element(
      [
        attribute.class("mt-auto"),
        button.prop_loading(model.post_lobby_request_loading),
        event.on_click(message.SubmitLobbyPostRequest),
      ],
      [html.text("Create Lobby")],
    ),
  ])
}
