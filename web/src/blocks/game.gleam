import blocks/game/board_view.{board_view}
import blocks/game/hand_view.{hand_view}
import blocks/game/x
import components/button
import core/game/board
import core/game/card
import core/game/classic.{type Classic, Classic}
import core/game/color
import core/game/player
import gleam/dict
import gleam/dynamic/decode
import gleam/option
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-game"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("game", {
      classic.decoder() |> decode.map(x.PropsChangedGame)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

fn init(_) {
  let game = new_game()
  let empty_board_moves = dict.map_values(game.board.cells, fn(_, _) { [] })

  #(
    x.Model(
      game:,
      empty_board_moves:,
      board_moves: empty_board_moves,
      board_marches: [],
      hover_index: option.None,
    ),
    effect.none(),
  )
}

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

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

fn update(model: x.Model, msg: x.Msg) {
  case msg {
    x.PropsChangedGame(game) -> {
      let #(board_moves, board_marches) = update_board_actions(model, game)
      #(x.Model(..model, game:, board_moves:, board_marches:), effect.none())
    }

    x.Unhover -> #(x.Model(..model, hover_index: option.None), effect.none())

    x.Hover(index) -> #(
      x.Model(..model, hover_index: option.Some(index)),
      effect.none(),
    )

    x.Move(source_index, dest_index) -> {
      let assert Ok(game) = classic.move(model.game, source_index, dest_index)
      let #(board_moves, board_marches) = update_board_actions(model, game)

      #(
        x.Model(
          ..model,
          game:,
          board_moves:,
          board_marches:,
          hover_index: option.None,
        ),
        effect.none(),
      )
    }

    x.March(index) -> {
      let assert Ok(game) = classic.march(model.game, index)
      let #(board_moves, board_marches) = update_board_actions(model, game)
      #(x.Model(..model, game:, board_moves:, board_marches:), effect.none())
    }

    x.Deploy(card) -> {
      let assert Ok(game) = classic.deploy(model.game, card)
      let #(board_moves, board_marches) = update_board_actions(model, game)
      #(x.Model(..model, game:, board_moves:, board_marches:), effect.none())
    }

    x.Pass -> {
      let assert Ok(game) = classic.pass(model.game)
      let #(board_moves, board_marches) = update_board_actions(model, game)
      #(x.Model(..model, game:, board_moves:, board_marches:), effect.none())
    }

    x.Undo -> {
      let assert Ok(game) = classic.undo_history(model.game)
      let #(board_moves, board_marches) = update_board_actions(model, game)
      #(x.Model(..model, game:, board_moves:, board_marches:), effect.none())
    }
  }
}

fn update_board_actions(model: x.Model, game: Classic) {
  case game.history {
    [classic.Move(source_index, _, _), ..] -> #(
      model.empty_board_moves,
      classic.get_marches(game, source_index),
    )

    [classic.March(source_index, _), ..] -> #(
      model.empty_board_moves,
      classic.get_marches(game, source_index),
    )

    [classic.Pass, ..] -> #(classic.get_moves(game), [])

    _ -> #(model.empty_board_moves, [])
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: x.Model) {
  html.div(
    [
      attribute.class("h-full p-4"),
      attribute.class("flex justify-center gap-12"),
    ],
    [
      html.div(
        [attribute.class("flex flex-col items-center justify-center gap-12")],
        [
          hand_view(model.game, model.game.black),
          board_view(model),
          hand_view(model.game, model.game.white),
        ],
      ),
      html.div(
        [attribute.class("flex flex-col items-center justify-center gap-4")],
        [
          // TODO: check if can end turn
          button.element([event.on_click(x.Pass)], [html.text("End Turn")]),
        ],
      ),
    ],
  )
}
