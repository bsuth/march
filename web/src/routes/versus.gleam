import blocks/game as game_ui
import core/game/board
import core/game/card
import core/game/classic.{type Classic, Classic}
import core/game/color
import core/game/player
import lustre
import lustre/attribute.{type Attribute}
import lustre/effect
import lustre/element
import lustre/element/html

// -----------------------------------------------------------------------------
// Model / Message
// -----------------------------------------------------------------------------

type Model =
  Classic

type Msg =
  Nil

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-versus"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [])
  |> lustre.register(element_name)
}

fn init(_) {
  let game = new_game()
  #(game, effect.none())
}

fn update(model: Model, _msg: Msg) {
  #(model, effect.none())
}

fn view(model: Model) {
  html.div(
    [
      attribute.class("h-full p-4"),
      attribute.class("flex justify-center gap-12"),
    ],
    [
      game_ui.element([attribute.property("game", classic.json(model))]),
    ],
  )
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

fn new_game() {
  let max_hand_size = 4
  let board_size = 4

  let #(black_hand, black_deck) = card.deal(max_hand_size)
  let #(white_hand, white_deck) = card.deal(max_hand_size)

  Classic(
    board: board.new(board_size),
    black: player.Managed(color.Black, black_hand, black_deck),
    white: player.Managed(color.White, white_hand, white_deck),
    active_player_color: color.Black,
    history: [],
  )
}
