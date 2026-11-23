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
  html.div(
    [
      attribute.class("h-full min-h-0 p-4"),
      attribute.class("flex flex-col items-center justify-center gap-4"),
    ],
    case model.loading_match, model.match {
      False, option.Some(match) -> [match_view(model, match)]

      False, option.None -> [
        phosphor.empty_regular([attribute.class("size-12")]),
        html.text("Match Not Found"),
      ]

      True, _ -> [
        phosphor.circle_notch_regular([
          attribute.class("size-12 animate-spin"),
        ]),
      ]
    },
  )
}

fn match_view(model: Model, match: Match) {
  let user_player_index =
    match.player_user_ids
    |> list.index_map(fn(player_user_id, index) { #(player_user_id, index) })
    |> list.find_map(fn(player_user_id_and_index) {
      case player_user_id_and_index.0 == model.app.user.id {
        True -> Ok(player_user_id_and_index.1)
        False -> Error(Nil)
      }
    })

  game_ui.element([
    attribute.class("size-full"),
    game_ui.engine_kernel(match.engine_kernel),
    game_ui.flipped(case match.engine_kernel.settings.doubles {
      True -> result.unwrap(user_player_index, 0) > 1
      False -> user_player_index == Ok(1)
    }),
    game_ui.on_turn_end(message.UserEndedTurn),
  ])
}
