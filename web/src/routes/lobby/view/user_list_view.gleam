import blocks/base_icon
import core/lobby.{type Lobby}
import core/user.{type User}
import gleam/list
import lib/player_color
import lustre/attribute
import lustre/element
import lustre/element/html
import phosphor
import routes/lobby/model.{type Model}
import yuzu

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
  let player_color =
    lobby.player_user_ids
    |> list.index_map(fn(player_user_id, player_index) {
      #(player_user_id, player_index)
    })
    |> list.find_map(fn(player_user_id_and_index) {
      use player_user_id <- yuzu.some(player_user_id_and_index.0, Error(Nil))
      use <- yuzu.true(player_user_id == user.id, Error(Nil))

      player_user_id_and_index.1
      |> player_color.from_player_index(lobby.engine_settings.doubles)
      |> Ok()
    })

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
    case player_color {
      Ok(player_color) ->
        base_icon.element([
          base_icon.player_color(player_color),
          base_icon.theme(model.app.theme),
          attribute.class("size-5"),
          attribute.title("Assigned to " <> player_color.label(player_color)),
        ])
      _ -> element.none()
    },
  ])
}
