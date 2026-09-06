import blocks/card
import blocks/game/message
import blocks/game/view/slot_view.{unknown_slot_view}
import engine.{type Engine}
import engine/board
import engine/player.{type Player}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element/html
import lustre/event

pub fn hand_view(engine: Engine, player: Player) {
  let player_base_index = board.get_base_index(engine.board, player.color)

  let needs_player_deployment =
    engine.active_player_color == player.color
    && board.is_none(engine.board, player_base_index)
    && !player.has_empty_hand(player)

  let children = case player {
    player.Managed(_, _, hand, _) | player.Controlled(_, _, hand, _) ->
      list.map(hand, fn(card) {
        card.element([
          card.value(card),
          case needs_player_deployment {
            True -> event.on_click(message.Deploy(card))
            False -> attribute.none()
          },
        ])
      })

    player.Observed(_, _, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_slot_view(player.color, []))
      })
  }

  html.div(
    [attribute.class("flex gap-4")],
    list.map(children, fn(child) {
      html.div([attribute.class("w-24 h-24 rounded overflow-hidden")], [child])
    }),
  )
}
