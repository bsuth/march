import blocks/board as ui_board
import blocks/card as ui_card
import components/button
import core/engine.{type Engine}
import core/engine/board
import core/engine/card.{type Card}
import core/engine/player
import core/engine/position
import core/engine/settings.{Settings}
import core/engine/turn
import core/util
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import lib/player_color.{type PlayerColor}
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

pub fn prop_engine(engine: Engine) {
  attribute.property("engine", engine.json(engine))
}

pub fn prop_player_index(player_index: Int) {
  attribute.property("player_index", json.int(player_index))
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
    component.on_property_change("engine", {
      engine.decoder() |> decode.map(PropsChangedEngine)
    }),
    component.on_property_change("player_index", {
      decode.int |> decode.map(PropsChangedPlayerIndex)
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
    engine: Engine,
    hover_index: Option(Int),
    player_index: Int,
    theme: Theme,
    turn_request: turn.Request,
    turn_request_engine: Engine,
  )
}

fn init(_) {
  let settings =
    Settings(
      board: board.normal(4, 4),
      doubles: False,
      hand_size: 4,
      traits: dict.new(),
    )

  let engine = engine.new(settings)

  #(
    Model(
      engine:,
      hover_index: option.None,
      player_index: 0,
      theme: theme.Light,
      turn_request: turn.Request(option.None, [], option.None),
      turn_request_engine: engine,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedEngine(Engine)
  PropsChangedPlayerIndex(Int)
  PropsChangedTheme(Theme)

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
    PropsChangedEngine(engine) -> {
      #(
        Model(
          ..model,
          engine:,
          turn_request_engine: engine.apply_turn_request(
            engine,
            model.turn_request,
          ),
        ),
        effect.none(),
      )
    }
    PropsChangedPlayerIndex(player_index) -> #(
      Model(..model, player_index:),
      effect.none(),
    )
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    Deploy(card) -> update_deploy(model, card)
    EndTurn -> update_end_turn(model)
    Hover(index) -> update_hover(model, index)
    March(_index) -> #(model, effect.none())
    Move(_source_index, _dest_index) -> #(model, effect.none())
    Undo -> update_undo(model)
    Unhover -> #(Model(..model, hover_index: option.None), effect.none())
  }
}

fn update_deploy(model: Model, card: Card) {
  let turn_request =
    turn.Request(..model.turn_request, deploy: option.Some(card))

  let turn_request_engine =
    engine.apply_turn_request(model.engine, turn_request)

  echo turn_request_engine

  #(Model(..model, turn_request:, turn_request_engine:), effect.none())
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
  let engine = model.turn_request_engine

  html.div(
    [
      attribute.class("h-full"),
      attribute.class("flex justify-center gap-8"),
    ],
    [
      html.div(
        [
          attribute.class("max-w-2xl flex-2"),
          attribute.class("flex flex-col justify-center items-center gap-8"),
        ],
        [
          player_hand_view(engine, False, case engine.settings.doubles {
            True -> { model.player_index + 2 } % 4
            False -> { model.player_index + 1 } % 2
          }),
          html.div(
            [
              attribute.class("w-full h-full"),
              attribute.class("flex justify-center items-center gap-8"),
            ],
            [
              case engine.settings.doubles {
                False -> element.none()
                True ->
                  player_hand_view(engine, True, { model.player_index + 1 } % 4)
              },
              ui_board.element([
                attribute.class("w-full h-full max-w-96 max-h-96"),
                ui_board.prop_player_index(model.player_index),
                ui_board.prop_position(engine.position),
                ui_board.prop_settings(engine.settings),
                ui_board.prop_theme(model.theme),
              ]),
              case engine.settings.doubles {
                False -> element.none()
                True ->
                  player_hand_view(engine, True, { model.player_index + 3 } % 4)
              },
            ],
          ),
          player_hand_view(engine, False, model.player_index),
        ],
      ),
      html.div(
        [
          attribute.class("flex-1 max-w-md"),
          attribute.class("flex flex-col items-center gap-4"),
          attribute.class("border rounded"),
        ],
        [end_turn_view(engine)],
      ),
    ],
  )
}

fn player_hand_view(engine: Engine, vertical: Bool, player_index: Int) {
  let assert Ok(player) = util.get_list_index(engine.players, player_index)

  let player_color =
    player_color.from_player_index(player_index, engine.settings.doubles)

  let player_base_index = settings.get_base_index(engine.settings, player_index)

  let can_deploy = {
    use <- yuzu.true(engine.active_player_index == player_index, False)
    use <- yuzu.true(!player.has_empty_hand(player), False)
    position.is_none(engine.position, player_base_index)
  }

  let children = case player {
    player.Managed(_, _, hand, _) | player.Controlled(_, _, hand, _) ->
      list.map(hand, fn(card) {
        ui_card.element([
          ui_card.prop_card(card),
          ui_card.prop_player_color(player_color),
          case can_deploy {
            True -> attribute.class("cursor-pointer")
            False -> attribute.none()
          },
          case can_deploy {
            True -> event.on_click(Deploy(card))
            False -> attribute.none()
          },
        ])
      })

    player.Observed(_, _, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_card_view(player_color))
      })
  }

  html.div(
    [
      attribute.class("flex gap-4"),
      case vertical {
        True -> attribute.class("flex-col")
        False -> attribute.none()
      },
    ],
    list.map(children, fn(child) {
      html.div([attribute.class("w-24 h-24 rounded overflow-hidden")], [child])
    }),
  )
}

fn unknown_card_view(player_color: PlayerColor) {
  let suit_class = attribute.class("size-6 -rotate-45")

  html.div(
    [
      attribute.class("h-full flex justify-center items-center"),
      case player_color {
        player_color.Black -> attribute.class("text-white bg-black")
        player_color.White -> attribute.class("text-black bg-white")
        player_color.LightRed -> attribute.class("text-black bg-red-200")
        player_color.DarkRed -> attribute.class("text-black bg-red-900")
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

fn end_turn_view(engine: Engine) {
  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  let active_player_base_index =
    settings.get_base_index(engine.settings, engine.active_player_index)

  case active_player {
    player.Observed(..) -> element.none()

    _ -> {
      let needs_player_deployment =
        position.is_none(engine.position, active_player_base_index)
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
