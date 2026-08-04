import entities/lobby_entity.{type LobbyEntity}
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}

// TODO: allow muting players
// TODO: allow kicking players (may need to unassign white / black when kicking)

pub fn lobby_members_list_view(model: Model, lobby: LobbyEntity) {
  html.ul(
    [attribute.class("flex flex-col gap-4")],
    list.flatten([
      [spectator_list_item_view(model, lobby, lobby.owner_user_id)],
      case lobby.black_user_id {
        option.Some(black_user_id) if black_user_id != lobby.owner_user_id -> [
          spectator_list_item_view(model, lobby, black_user_id),
        ]
        _ -> []
      },
      case lobby.white_user_id {
        option.Some(white_user_id) if white_user_id != lobby.owner_user_id -> [
          spectator_list_item_view(model, lobby, white_user_id),
        ]
        _ -> []
      },
      list.map(lobby.spectator_user_ids, fn(user_id) {
        spectator_list_item_view(model, lobby, user_id)
      }),
    ]),
  )
}

fn spectator_list_item_view(model: Model, lobby: LobbyEntity, user_id: String) {
  let is_assigned_to_white = case lobby.white_user_id {
    option.Some(white_user_id) -> white_user_id == user_id
    option.None -> False
  }

  let is_assigned_to_black = case lobby.black_user_id {
    option.Some(black_user_id) -> black_user_id == user_id
    option.None -> False
  }

  html.li([attribute.class("flex gap-2 items-center")], [
    case model.app.user_id == lobby.owner_user_id {
      False -> element.none()
      True ->
        html.div([attribute.title("Lobby Owner")], [
          phosphor.star_fill([attribute.class("size-5")]),
        ])
    },
    html.p(
      [
        attribute.class("flex-1"),
        attribute.class("overflow-hidden whitespace-nowrap text-ellipsis"),
        attribute.title(user_id),
      ],
      [html.text(user_id)],
    ),
    case model.app.user_id == lobby.owner_user_id, is_assigned_to_white {
      False, _ | _, True -> element.none()
      True, False ->
        html.div(
          [
            attribute.class("size-5"),
            attribute.class("bg-zinc-50 rounded-full"),
            attribute.class("cursor-pointer"),
            attribute.title("Assign to White"),
            event.on_click(message.UserAssignedWhite(user_id)),
          ],
          [],
        )
    },
    case model.app.user_id == lobby.owner_user_id, is_assigned_to_black {
      False, _ | _, True -> element.none()
      True, False ->
        html.div(
          [
            attribute.class("size-5"),
            attribute.class("border border-zinc-50 rounded-full"),
            attribute.class("cursor-pointer"),
            attribute.title("Assign to Black"),
            event.on_click(message.UserAssignedBlack(user_id)),
          ],
          [],
        )
    },
  ])
}
