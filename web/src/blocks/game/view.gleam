import blocks/board
import blocks/game/message
import blocks/game/model.{type Model}
import blocks/game/view/player_view
import components/button
import engine/color
import lustre/attribute
import lustre/element/html
import lustre/event

pub fn view(model: Model) {
  let top_player = case model.color {
    color.Black -> model.engine.white
    color.White -> model.engine.black
  }

  let bottom_player = case model.color {
    color.Black -> model.engine.black
    color.White -> model.engine.white
  }

  html.div(
    [
      attribute.class("h-full p-4"),
      attribute.class("flex justify-center gap-12"),
    ],
    [
      // TODO: allow ability to flip colors
      html.div(
        [
          attribute.class(
            "flex flex-col items-center justify-center gap-12 h-full",
          ),
        ],
        [
          player_view.hand_view(model.engine, top_player),
          board.element([
            attribute.class("w-full"),
            board.board(model.engine.board),
            board.color(model.color),
            board.theme(model.theme),
          ]),
          player_view.hand_view(model.engine, bottom_player),
        ],
      ),
      html.div(
        [attribute.class("flex flex-col items-center justify-center gap-4")],
        [
          // TODO: check if can end turn
          button.element([event.on_click(message.Pass)], [html.text("End Turn")]),
        ],
      ),
    ],
  )
}
