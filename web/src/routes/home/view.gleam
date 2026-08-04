import components/button
import components/field
import components/single_select
import components/text_input
import components/toggle
import engine/variant
import gleam/int
import http_api/http_lobby
import lib/labels
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
            http_lobby.PostRequest(..model.post_lobby_request, name: value)
            |> message.UpdateLobbyPostRequest()
          }),
        ]),
      ]),
      field.element([field.label("Variant")], [
        single_select.element([
          model.post_lobby_request.variant
            |> variant.to_string()
            |> single_select.value(),
          single_select.options([
            #("standard", labels.variant(variant.Standard)),
            #("classic", labels.variant(variant.Classic)),
          ]),
          single_select.on_change(fn(variant_string) {
            let assert Ok(variant) = variant.from_string(variant_string)
            http_lobby.PostRequest(..model.post_lobby_request, variant:)
            |> message.UpdateLobbyPostRequest()
          }),
        ]),
      ]),
      field.element([field.label("Board")], [
        single_select.element([
          single_select.value(
            case
              model.post_lobby_request.board_width,
              model.post_lobby_request.board_height
            {
              3, 3 -> "3_by_3"
              _, _ -> "4_by_4"
            },
          ),
          single_select.options([
            #("4_by_4", "4 x 4"),
            #("3_by_3", "3 x 3"),
          ]),
          single_select.on_change(fn(board_string) {
            let #(board_width, board_height) = case board_string {
              "3_by_3" -> #(3, 3)
              _ -> #(4, 4)
            }

            http_lobby.PostRequest(
              ..model.post_lobby_request,
              board_width:,
              board_height:,
            )
            |> message.UpdateLobbyPostRequest()
          }),
        ]),
      ]),
      field.element([field.label("Public")], [
        toggle.element([
          toggle.value(model.post_lobby_request.is_public),
          toggle.on_update(fn(value) {
            http_lobby.PostRequest(..model.post_lobby_request, is_public: value)
            |> message.UpdateLobbyPostRequest()
          }),
        ]),
      ]),
      button.element(
        [
          attribute.class("mt-auto"),
          button.loading(model.post_lobby_request_loading),
          event.on_click(message.SubmitLobbyPostRequest),
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
        phosphor.user_fill([attribute.class("size-5")]),
      ]),
    ],
  )
}
