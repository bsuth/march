import core/lobby.{type Lobby}
import core/user.{type User}
import gleam/list
import gleam/option
import lib/labels
import lustre/attribute.{type Attribute}
import lustre/element
import lustre/element/html
import lustre/event
import phosphor
import routes/lobby/message
import routes/lobby/model.{type Model}

// TODO: allow muting players
// TODO: allow kicking players

pub fn lobby_members_list_view(model: Model, lobby: Lobby) {
  html.ul(
    [attribute.class("flex flex-col gap-4")],
    list.flatten([
      list.map(lobby.users, fn(user) {
        lobby_member_list_item_view(model, lobby, user)
      }),
    ]),
  )
}

fn lobby_member_list_item_view(model: Model, lobby: Lobby, user: User) {
  let is_assigned_to_white = case lobby.white {
    option.Some(white) -> white.id == user.id
    option.None -> False
  }

  let is_assigned_to_black = case lobby.black {
    option.Some(black) -> black.id == user.id
    option.None -> False
  }

  html.li([attribute.class("flex gap-2 items-center")], [
    case is_assigned_to_black {
      False -> element.none()
      True ->
        black_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assigned to Black"),
          event.on_click(message.UserChangedBlack(option.None)),
        ])
    },
    case is_assigned_to_white {
      False -> element.none()
      True ->
        white_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assigned to White"),
          event.on_click(message.UserChangedWhite(option.None)),
        ])
    },
    case user.id == lobby.owner.id {
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
        attribute.title(labels.user(user)),
        case user.id == model.app.user.id {
          True -> attribute.class("text-blue-700 dark:text-blue-400")
          False -> attribute.none()
        },
      ],
      [html.text(labels.user(user))],
    ),
    case model.app.user.id == lobby.owner.id {
      False -> element.none()
      True ->
        black_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assign to Black"),
          event.on_click(message.UserChangedBlack(option.Some(user.id))),
        ])
    },
    case model.app.user.id == lobby.owner.id {
      False -> element.none()
      True ->
        white_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assign to White"),
          event.on_click(message.UserChangedWhite(option.Some(user.id))),
        ])
    },
  ])
}

fn black_indicator(attrs: List(Attribute(message))) {
  html.div(
    [
      attribute.class("size-5"),
      attribute.class("dark:border border-zinc-50 bg-zinc-900"),
      attribute.class("rounded-full"),
      ..attrs
    ],
    [],
  )
}

fn white_indicator(attrs: List(Attribute(message))) {
  html.div(
    [
      attribute.class("size-5"),
      attribute.class("light:border border-zinc-900 bg-zinc-50"),
      attribute.class("rounded-full"),
      ..attrs
    ],
    [],
  )
}
