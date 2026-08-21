import blocks/game/model.{Model}
import engine.{Engine}
import engine/board
import engine/card
import engine/color
import engine/player
import engine/variant
import gleam/option
import lib/theme
import lustre/effect

pub fn init() {
  let board_size = 4
  let hand_size = 4

  let #(black_hand, black_deck) =
    card.deal(variant.Classic, color.Black, hand_size)

  let #(white_hand, white_deck) =
    card.deal(variant.Classic, color.White, hand_size)

  let engine =
    Engine(
      active_player_color: color.Black,
      black: player.Managed(color.Black, black_deck, black_hand, hand_size),
      board: board.new(board_size, board_size),
      history: [],
      white: player.Managed(color.White, white_deck, white_hand, hand_size),
    )

  #(
    Model(
      color: color.White,
      engine:,
      hover_index: option.None,
      theme: theme.Light,
    ),
    effect.none(),
  )
}
