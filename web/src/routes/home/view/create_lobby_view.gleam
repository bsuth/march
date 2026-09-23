import components/button
import components/field
import components/text_input
import components/toggle
import http_api/http_lobby
import lustre/attribute
import lustre/element/html
import lustre/event
import routes/home/message
import routes/home/model.{type Model}

pub fn create_lobby_view(model: Model) {
  html.div([attribute.class("w-48 flex flex-col gap-4")], [
    field.element([field.prop_label("Name")], [
      text_input.element([
        text_input.prop_value(model.post_lobby_request.name),
        text_input.on_change(fn(value) {
          http_lobby.PostRequest(..model.post_lobby_request, name: value)
          |> message.UpdateLobbyPostRequest()
        }),
      ]),
    ]),
    field.element([field.prop_label("Public")], [
      toggle.element([
        toggle.prop_value(model.post_lobby_request.visible),
        toggle.on_update(fn(value) {
          http_lobby.PostRequest(..model.post_lobby_request, visible: value)
          |> message.UpdateLobbyPostRequest()
        }),
      ]),
    ]),
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
