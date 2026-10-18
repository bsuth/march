import blocks/game as game_ui
import core/match.{type Match}
import gleam/list
import gleam/option
import gleam/result
import lustre/attribute
import lustre/element/html
import phosphor
import routes/match/message
import routes/match/model.{type Model}

pub fn view(model: Model) {
  case model.loading_match, model.match {
    False, option.Some(match) -> match_view(model, match)

    False, option.None ->
      html.div(
        [
          attribute.class("h-full"),
          attribute.class("flex flex-col items-center justify-center gap-4"),
        ],
        [
          phosphor.empty_regular([attribute.class("size-12")]),
          html.text("Match Not Found"),
        ],
      )

    True, _ ->
      html.div(
        [
          attribute.class("h-full"),
          attribute.class("flex flex-col items-center justify-center gap-4"),
        ],
        [
          phosphor.circle_notch_regular([
            attribute.class("size-12 animate-spin"),
          ]),
        ],
      )
  }
}

fn match_view(model: Model, match: Match) {
  let user_player_index =
    match.players
    |> list.index_map(fn(player, index) { #(player, index) })
    |> list.find_map(fn(player_and_index) {
      case player_and_index.0.id == model.app.user.id {
        True -> Ok(player_and_index.1)
        False -> Error(Nil)
      }
    })

  html.div([attribute.class("h-full p-4")], [
    game_ui.element([
      game_ui.prop_engine_kernel(match.engine_kernel),
      game_ui.prop_flipped(case match.engine_kernel.settings.doubles {
        True -> result.unwrap(user_player_index, 0) > 1
        False -> user_player_index == Ok(1)
      }),
      game_ui.prop_theme(model.app.theme),
      game_ui.on_turn_end(message.UserEndedTurn),
    ]),
  ])
}
