import blocks/board as ui_board
import blocks/card as ui_card
import components/button
import engine.{type ActiveTurn, type Engine, Engine}
import engine/board
import engine/board/cell.{type Cell}
import engine/card.{type Card}
import engine/color.{type Color}
import engine/player.{type Player}
import engine/variant
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{type Option}
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import phosphor
import yuzu

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_color(color: Color) {
  attribute.property("color", color.json(color))
}

pub fn prop_engine(engine: Engine) {
  attribute.property("engine", engine.json(engine))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-game"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("color", {
      color.decoder() |> decode.map(PropsChangedColor)
    }),
    component.on_property_change("engine", {
      engine.decoder() |> decode.map(PropsChangedEngine)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(PropsChangedTheme)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(
    active_turn: ActiveTurn,
    color: Color,
    engine: Engine,
    hover_index: Option(Int),
    theme: Theme,
  )
}

fn init(_) {
  // TODO: make this configurable
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
      white: player.Managed(color.White, white_deck, white_hand, hand_size),
    )

  #(
    Model(
      active_turn: engine.ActiveStartTurn,
      color: color.White,
      engine:,
      hover_index: option.None,
      theme: theme.Light,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedColor(Color)
  PropsChangedEngine(Engine)
  PropsChangedTheme(Theme)

  CellClick(Cell)
  Deploy(Card)
  EndTurn
  Hover(Int)
  Unhover
  Move(Int, Int)
  March(Int)
  Undo
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedColor(color) -> #(Model(..model, color:), effect.none())
    PropsChangedEngine(engine) -> #(Model(..model, engine:), effect.none())
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    CellClick(cell) -> update_cell_click(model, cell)
    Deploy(card) -> update_deploy(model, card)
    EndTurn -> update_end_turn(model)
    Hover(index) -> update_hover(model, index)
    March(_index) -> #(model, effect.none())
    Move(_source_index, _dest_index) -> #(model, effect.none())
    Undo -> update_undo(model)
    Unhover -> #(Model(..model, hover_index: option.None), effect.none())
  }
}

fn update_cell_click(model: Model, cell: Cell) {
  echo cell
  #(model, effect.none())
}

fn update_deploy(model: Model, card: Card) {
  use engine <- yuzu.ok(engine.deploy(model.engine, option.Some(card)), #(
    model,
    effect.none(),
  ))

  let active_turn = case model.active_turn {
    engine.ActiveStartTurn -> engine.ActiveDeployOnlyTurn(card)
    engine.ActiveMarchTurn(move, marches) ->
      engine.ActiveDeployTurn(move, marches, card)
    engine.ActiveDeployTurn(move, marches, _) ->
      engine.ActiveDeployTurn(move, marches, card)
    engine.ActiveDeployOnlyTurn(_) -> engine.ActiveDeployOnlyTurn(card)
  }

  #(Model(..model, active_turn:, engine:), effect.none())
}

fn update_end_turn(model: Model) {
  // TODO: validate active_turn and send to server
  #(model, effect.none())
}

fn update_hover(model: Model, index: Int) {
  #(Model(..model, hover_index: option.Some(index)), effect.none())
}

fn update_undo(model: Model) {
  // TODO
  #(model, effect.none())
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
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
      attribute.class("h-full"),
      attribute.class("flex justify-center gap-8"),
    ],
    [
      // TODO: allow ability to flip colors
      html.div(
        [
          attribute.class("max-w-2xl flex-2"),
          attribute.class("flex flex-col justify-center items-center gap-8"),
        ],
        [
          player_hand_view(model.engine, top_player),
          ui_board.element([
            attribute.class("w-full h-full max-w-96 max-h-96"),
            ui_board.prop_board(model.engine.board),
            ui_board.prop_color(model.color),
            ui_board.prop_theme(model.theme),
            ui_board.on_cell_click(CellClick),
          ]),
          player_hand_view(model.engine, bottom_player),
        ],
      ),
      html.div(
        [
          attribute.class("flex-1 max-w-md"),
          attribute.class("flex flex-col items-center gap-4"),
          attribute.class("border rounded"),
        ],
        [end_turn_view(model)],
      ),
    ],
  )
}

fn player_hand_view(engine: Engine, player: Player) {
  let player_base_index = board.get_base_index(engine.board, player.color)

  let needs_player_deployment =
    engine.active_player_color == player.color
    && board.is_none(engine.board, player_base_index)
    && !player.has_empty_hand(player)

  let children = case player {
    player.Managed(_, _, hand, _) | player.Controlled(_, _, hand, _) ->
      list.map(hand, fn(card) {
        ui_card.element([
          ui_card.prop_value(card),
          case needs_player_deployment {
            True -> event.on_click(Deploy(card))
            False -> attribute.none()
          },
        ])
      })

    player.Observed(_, _, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_card_view(player.color))
      })
  }

  html.div(
    [attribute.class("flex gap-4")],
    list.map(children, fn(child) {
      html.div([attribute.class("w-24 h-24 rounded overflow-hidden")], [child])
    }),
  )
}

fn unknown_card_view(color: Color) {
  let suit_class = attribute.class("size-6 -rotate-45")

  html.div(
    [
      attribute.class("h-full flex justify-center items-center"),
      case color {
        color.Black -> attribute.class("text-white bg-black")
        color.White -> attribute.class("text-black bg-white")
      },
    ],
    [
      html.div([attribute.class("grid grid-cols-2 gap-1 rotate-45")], [
        phosphor.spade_fill([suit_class]),
        phosphor.diamond_fill([suit_class, attribute.class("text-red-400")]),
        phosphor.heart_fill([suit_class, attribute.class("text-red-400")]),
        phosphor.club_fill([suit_class]),
      ]),
    ],
  )
}

fn end_turn_view(model: Model) {
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

      // TODO: check if has moved (when possible)
      let can_end_turn = !needs_player_deployment

      button.element(
        [button.prop_disabled(!can_end_turn), event.on_click(EndTurn)],
        [html.text("End Turn")],
      )
    }
  }
}
