import core/lobby.{type Lobby}
import core/user.{type User}
import core/util
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import phosphor
import routes/lobby/model.{type Model}

// TODO: allow muting players
// TODO: allow kicking players

pub fn user_list_view(model: Model, lobby: Lobby) {
  html.ul(
    [attribute.class("flex flex-col gap-4")],
    list.flatten([
      list.map(lobby.users, user_view(model, lobby, _)),
    ]),
  )
}

fn user_view(model: Model, lobby: Lobby, user: User) {
  let player_index =
    util.find_list_index(lobby.player_user_ids, option.Some(user.id))

  html.li([attribute.class("flex gap-2 items-center")], [
    html.p(
      [
        attribute.class("flex-1"),
        attribute.class("overflow-hidden whitespace-nowrap text-ellipsis"),
        attribute.title(user.name),
        case user.id == model.app.user.id {
          True -> attribute.class("text-blue-700 dark:text-blue-400")
          False -> attribute.none()
        },
      ],
      [html.text(user.name)],
    ),
    case user.id == lobby.owner_user_id {
      False -> element.none()
      True ->
        html.div([attribute.title("Lobby Owner")], [
          phosphor.star_fill([attribute.class("size-5")]),
        ])
    },
    case player_index {
      Ok(player_index) ->
        html.div(
          [attribute.title("Player " <> int.to_string(player_index + 1))],
          [html.text(int.to_string(player_index + 1))],
        )
      _ -> element.none()
    },
  ])
}
