import blocks/old_game/slot_view.{unit_slot_view, unknown_slot_view}
import blocks/old_game/x
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element/html
import old_engine/board
import old_engine/classic.{type Classic}
import old_engine/player.{type Player}
import old_engine/unit.{Unit}

pub fn hand_view(game: Classic, player: Player) {
  let player_base_index = classic.get_base_index(game.board, player.color)

  let needs_player_deployment =
    game.active_player_color == player.color
    && board.is_none(game.board, player_base_index)
    && !player.has_empty_hand(player)

  let children = case player {
    player.Managed(_, hand, _) | player.Controlled(_, hand, _) ->
      list.map(hand, fn(card) {
        unit_slot_view(
          Unit(card, player.color),
          case needs_player_deployment {
            True -> option.Some(x.Deploy(card))
            False -> option.None
          },
          [],
        )
      })

    player.Observed(_, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_slot_view(player.color, []))
      })
  }

  html.div([attribute.class("flex gap-4")], children)
}
