import blocks/game/message
import blocks/game/view/slot_view.{card_slot_view, unknown_slot_view}
import engine.{type Engine}
import engine/board
import engine/player.{type Player}
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element/html

pub fn hand_view(engine: Engine, player: Player) {
  let player_base_index = board.get_base_index(engine.board, player.color)

  let needs_player_deployment =
    engine.active_player_color == player.color
    && board.is_none(engine.board, player_base_index)
    && !player.has_empty_hand(player)

  let children = case player {
    player.Managed(_, _, hand, _) | player.Controlled(_, _, hand, _) ->
      list.map(hand, fn(card) {
        card_slot_view(
          card,
          case needs_player_deployment {
            True -> option.Some(message.Deploy(card))
            False -> option.None
          },
          [],
        )
      })

    player.Observed(_, _, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_slot_view(player.color, []))
      })
  }

  html.div([attribute.class("flex gap-4")], children)
}
