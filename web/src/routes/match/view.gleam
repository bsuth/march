import blocks/game as game_ui
import core/match.{type Match}
import gleam/option
import lustre/attribute
import lustre/element/html
import phosphor
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
  html.div([attribute.class("h-full p-4")], [
    game_ui.element([
      attribute.class("h-full"),
      game_ui.color(model.color),
      game_ui.engine(match.engine),
      game_ui.theme(model.app.theme),
    ]),
  ])
}
