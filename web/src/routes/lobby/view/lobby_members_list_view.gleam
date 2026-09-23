import core/lobby.{type Lobby}
import core/user.{type User}
import gleam/list
import gleam/result
import lib/labels
import lib/player_color
import lustre/attribute.{type Attribute}
import lustre/element
import lustre/element/html
import phosphor
import routes/lobby/model.{type Model}
import yuzu

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
  let player_index =
    lobby.players
    |> list.index_map(fn(user, player_index) { #(user, player_index) })
    |> list.find_map(fn(lobby_player) {
      use player_user <- yuzu.some(lobby_player.0, Error(Nil))
      use <- yuzu.true(player_user == user, Error(Nil))
      Ok(lobby_player.1)
    })

  let player_color =
    result.map(player_index, fn(player_index) {
      player_color.from_player_index(
        player_index,
        lobby.engine_settings.doubles,
      )
    })

  // TODO: handle other colors

  html.li([attribute.class("flex gap-2 items-center")], [
    case player_color == Ok(player_color.Black) {
      False -> element.none()
      True ->
        black_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assigned to Black"),
        ])
    },
    case player_color == Ok(player_color.White) {
      False -> element.none()
      True ->
        white_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assigned to White"),
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
        ])
    },
    case model.app.user.id == lobby.owner.id {
      False -> element.none()
      True ->
        white_indicator([
          attribute.class("cursor-pointer"),
          attribute.title("Assign to White"),
        ])
    },
  ])
}

fn black_indicator(attrs: List(Attribute(message))) {
  html.div(
    [
      attribute.class("size-5"),
      attribute.class("dark:border border-neutral-50 bg-neutral-900"),
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
      attribute.class("light:border border-neutral-900 bg-neutral-50"),
      attribute.class("rounded-full"),
      ..attrs
    ],
    [],
  )
}
