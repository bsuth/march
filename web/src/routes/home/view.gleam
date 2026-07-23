import api
import components/button
import components/field
import components/single_select
import components/text_input
import components/toggle
import gleam/int
import lustre/attribute
import lustre/element/html
import lustre/event
import phosphor
import routes/home/message
import routes/home/model.{type Model}

pub fn view(model: Model) {
  html.div([attribute.class("m-auto"), attribute.class("flex gap-4")], [
    // TODO: handle empty state
    html.ul(
      [
        attribute.class("w-2xl min-h-96"),
        attribute.class("flex flex-col"),
        attribute.class("border rounded overflow-hidden"),
      ],
      [
        // TODO: use real data
        // TODO: handle joining lobby
        lobby_list_item("My Fake Lobby", "crouch#fx3k2d", 1),
        lobby_list_item("My Other Lobby", "frypan#12ai3e", 1),
        lobby_list_item("1v1 only", "blah#e8797e", 1),
      ],
    ),
    html.div([attribute.class("w-48 flex flex-col gap-4")], [
      field.element([field.label("Name")], [
        text_input.element([
          text_input.value(model.post_lobby_request.name),
          text_input.on_change(fn(value) {
            api.PostLobbyRequest(..model.post_lobby_request, name: value)
            |> message.UpdatePostLobbyRequest()
          }),
        ]),
      ]),
      field.element([field.label("Variant")], [
        single_select.element([]),
      ]),
      field.element([field.label("Public")], [
        toggle.element([
          toggle.value(model.post_lobby_request.public),
          toggle.on_update(fn(value) {
            api.PostLobbyRequest(..model.post_lobby_request, public: value)
            |> message.UpdatePostLobbyRequest()
          }),
        ]),
      ]),
      button.element(
        [
          attribute.class("mt-auto"),
          button.loading(model.post_lobby_request_loading),
          event.on_click(message.SubmitPostLobbyRequest),
        ],
        [html.text("Create Lobby")],
      ),
    ]),
  ])
}

fn lobby_list_item(lobby_name: String, owner_name: String, population: Int) {
  html.li(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex items-center justify-between"),
      attribute.class("hover:bg-zinc-200 dark:hover:bg-zinc-700"),
      attribute.class("cursor-pointer"),
    ],
    [
      html.div([attribute.class("flex flex-col")], [
        html.p([attribute.class("font-bold")], [
          html.text(lobby_name),
        ]),
        html.p([attribute.class("text-sm")], [
          html.text(owner_name),
        ]),
      ]),
      html.p([attribute.class("flex items-center gap-1")], [
        html.text(int.to_string(population)),
        phosphor.user_fill([attribute.class("w-5 h-5")]),
      ]),
    ],
  )
}
