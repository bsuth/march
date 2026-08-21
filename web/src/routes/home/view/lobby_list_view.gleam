import core/lobby.{type Lobby}
import gleam/list
import gleam/string
import lib/labels
import lustre/attribute
import lustre/element/html
import lustre/event
import phosphor
import routes/home/message
import routes/home/model.{type Model}

pub fn lobby_list_view(model: Model) {
  html.ul(
    [
      attribute.class("w-2xl min-h-96"),
      attribute.class("flex flex-col"),
      attribute.class("border rounded overflow-hidden"),
    ],
    case model.get_lobby_list_loading, list.is_empty(model.lobbies) {
      False, False -> list.map(model.lobbies, lobby_list_item)

      False, True -> [
        html.div(
          [
            attribute.class("h-full"),
            attribute.class("flex flex-col items-center justify-center gap-4"),
          ],
          [
            phosphor.empty_regular([attribute.class("size-12")]),
            html.text("No Lobbies Found"),
          ],
        ),
      ]

      True, _ -> [
        html.div([attribute.class("h-full flex items-center justify-center")], [
          phosphor.circle_notch_regular([
            attribute.class("size-12 animate-spin"),
          ]),
        ]),
      ]
    },
  )
}

fn lobby_list_item(lobby: Lobby) {
  html.li(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex items-center justify-between"),
      attribute.class("hover:bg-zinc-200 dark:hover:bg-zinc-700"),
      attribute.class("cursor-pointer"),
      event.on_click(message.UserClickedLobby(lobby)),
    ],
    [
      html.div([attribute.class("flex flex-col")], [
        html.p([attribute.class("font-bold")], [
          html.text(case string.trim(lobby.name) {
            "" -> "Untitled Lobby"
            _ -> lobby.name
          }),
        ]),
        html.p([attribute.class("text-sm")], [
          html.text(labels.user(lobby.owner)),
        ]),
      ]),
      html.div([attribute.class("flex flex-col text-right")], [
        html.p([], [
          html.text(labels.variant(lobby.variant)),
        ]),
        html.p([attribute.class("text-sm")], [
          html.text(labels.board(lobby.board_width, lobby.board_height)),
        ]),
      ]),
    ],
  )
}
