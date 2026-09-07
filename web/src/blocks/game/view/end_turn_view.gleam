import blocks/game/message
import blocks/game/model.{type Model}
import components/button
import engine
import engine/board
import engine/player
import lustre/element
import lustre/element/html
import lustre/event

pub fn end_turn_view(model: Model) {
  let engine = model.engine

  let active_player = engine.get_active_player(engine)
  let active_player_base_index =
    board.get_base_index(engine.board, active_player.color)

  case active_player {
    player.Observed(..) -> element.none()

    _ -> {
      let needs_player_deployment =
        board.is_none(engine.board, active_player_base_index)
        && !player.has_empty_hand(active_player)

      let can_end_turn = !needs_player_deployment

      button.element(
        [button.disabled(!can_end_turn), event.on_click(message.EndTurn)],
        [html.text("End Turn")],
      )
    }
  }
}
