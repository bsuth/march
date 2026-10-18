import blocks/game_board
import blocks/game_history
import blocks/player_hand
import components/button
import core/engine.{type Engine}
import core/engine/board
import core/engine/card.{type Card}
import core/engine/player
import core/engine/settings.{Settings}
import core/engine/turn
import core/util
import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
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

pub fn prop_engine_kernel(engine_kernel: engine.Kernel) {
  attribute.property("engine_kernel", engine.kernel_json(engine_kernel))
}

pub fn prop_flipped(flipped: Bool) {
  attribute.property("flipped", json.bool(flipped))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

pub fn on_turn_end(handler: fn(turn.Request) -> message) {
  event.on(
    "turn_end",
    ["detail"] |> decode.at(turn.request_decoder()) |> decode.map(handler),
  )
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
    component.on_property_change("engine_kernel", {
      engine.kernel_decoder() |> decode.map(PropsChangedEngineKernel)
    }),
    component.on_property_change("flipped", {
      decode.bool |> decode.map(PropsChangedFlipped)
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
    flipped: Bool,
    hover_index: Option(Int),
    preview_engine: Option(Engine),
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

  let kernel = engine.new_kernel(settings)
  let engine = engine.new(kernel)

  #(
    Model(
      engine:,
      flipped: False,
      hover_index: option.None,
      preview_engine: option.None,
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
  PropsChangedEngineKernel(engine.Kernel)
  PropsChangedFlipped(Bool)
  PropsChangedTheme(Theme)

  ClearPreview
  Deploy(Card)
  EndTurn
  OnUpdateTurnRequest(turn.Request)
  PreviewTurn(Int)
  Undo
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedEngineKernel(engine_kernel) -> {
      let engine = engine.new(engine_kernel)

      #(
        Model(
          ..model,
          engine:,
          turn_request: turn.Request(option.None, [], option.None),
          turn_request_engine: engine,
        ),
        effect.none(),
      )
    }
    PropsChangedFlipped(flipped) -> #(Model(..model, flipped:), effect.none())
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    ClearPreview -> #(
      Model(..model, preview_engine: option.None),
      effect.none(),
    )
    Deploy(card) -> update_deploy(model, card)
    EndTurn -> update_end_turn(model)
    OnUpdateTurnRequest(turn_request) -> #(
      Model(
        ..model,
        turn_request:,
        turn_request_engine: engine.preview_turn_request(
          model.engine,
          turn_request,
        ),
      ),
      effect.none(),
    )
    PreviewTurn(turn_index) -> update_preview_turn(model, turn_index)
    Undo -> update_undo(model)
  }
}

fn update_deploy(model: Model, card: Card) {
  use <- yuzu.true(
    model.turn_request_engine.kernel.settings
      |> settings.get_base_index(model.turn_request_engine.active_player_index)
      |> dict.get(model.turn_request_engine.position, _)
      |> result.unwrap(option.None)
      |> option.is_none()
      |> bool.or(option.is_some(model.turn_request.deploy)),
    #(model, effect.none()),
  )

  let turn_request =
    turn.Request(..model.turn_request, deploy: option.Some(card))

  let turn_request_engine =
    engine.preview_turn_request(model.engine, turn_request)

  #(Model(..model, turn_request:, turn_request_engine:), effect.none())
}

fn update_end_turn(model: Model) {
  #(model, event.emit("turn_end", turn.request_json(model.turn_request)))
}

fn update_preview_turn(model: Model, turn_index: Int) {
  let is_previewing_live_turn =
    option.is_none(model.turn_request.lead)
    && option.is_none(model.turn_request.deploy)
    && turn_index == list.length(model.engine.kernel.turns) - 1

  case is_previewing_live_turn {
    True -> #(Model(..model, preview_engine: option.None), effect.none())

    False -> #(
      Model(
        ..model,
        preview_engine: model.engine.kernel
          |> engine.replay(turn_index)
          |> option.Some(),
      ),
      effect.none(),
    )
  }
}

fn update_undo(model: Model) {
  let turn_request = turn.undo(model.turn_request)

  let turn_request_engine =
    engine.preview_turn_request(model.engine, turn_request)

  #(Model(..model, turn_request:, turn_request_engine:), effect.none())
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let engine = case model.preview_engine {
    option.Some(preview_engine) -> preview_engine
    option.None -> model.turn_request_engine
  }

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
          player_hand_view(model, case engine.kernel.settings.doubles {
            True -> 2
            False -> 1
          }),
          html.div(
            [
              attribute.class("w-full h-full"),
              attribute.class("flex justify-center items-center gap-8"),
            ],
            [
              case engine.kernel.settings.doubles {
                True -> player_hand_view(model, 1)
                False -> element.none()
              },
              // TODO: use raw `board.element` for preview engine to prevent
              // mutating preview board
              game_board.element([
                attribute.class("w-full h-full"),
                game_board.prop_engine(engine),
                game_board.prop_flipped(model.flipped),
                game_board.prop_theme(model.theme),
                game_board.prop_turn_request(model.turn_request),
                game_board.on_update_turn_request(OnUpdateTurnRequest),
              ]),
              case engine.kernel.settings.doubles {
                True -> player_hand_view(model, 3)
                False -> element.none()
              },
            ],
          ),
          player_hand_view(model, 0),
        ],
      ),
      html.div(
        [
          attribute.class("flex-1 max-w-md"),
          attribute.class("flex flex-col items-center gap-4"),
          attribute.class("border rounded"),
        ],
        [
          game_history.element([
            game_history.prop_settings(model.engine.kernel.settings),
            game_history.prop_turns(model.engine.kernel.turns),
            game_history.on_turn_click(PreviewTurn),
            attribute.class("w-full"),
          ]),
          case engine.loser {
            option.Some(loser_player_index) ->
              html.div([], [
                html.text("LOSER: " <> int.to_string(loser_player_index)),
              ])
            option.None -> element.none()
          },
          html.div(
            [attribute.class("mt-auto pb-2 flex gap-2")],
            case model.preview_engine {
              option.Some(_) -> [
                button.element(
                  [button.prop_disabled(False), event.on_click(ClearPreview)],
                  [html.text("Back to Live")],
                ),
              ]
              option.None -> [
                undo_button_view(model),
                end_turn_button_view(model),
              ]
            },
          ),
        ],
      ),
    ],
  )
}

fn player_hand_view(model: Model, player_index: Int) {
  let engine = case model.preview_engine {
    option.Some(preview_engine) -> preview_engine
    option.None -> model.turn_request_engine
  }

  let player_index = case model.flipped, engine.kernel.settings.doubles {
    True, True -> { player_index + 2 } % 4
    True, False -> { player_index + 1 } % 2
    _, _ -> player_index
  }

  let assert Ok(player) = util.get_list_index(engine.players, player_index)

  player_hand.element([
    player_hand.prop_player(player),
    player_hand.prop_vertical(
      engine.kernel.settings.doubles && player_index % 2 == 1,
    ),
    case player.index == engine.active_player_index {
      True -> player_hand.on_card_click(Deploy)
      False -> attribute.none()
    },
  ])
}

fn undo_button_view(model: Model) {
  let engine = model.turn_request_engine

  use <- yuzu.true(
    option.is_some(model.turn_request.lead)
      || option.is_some(model.turn_request.deploy),
    element.none(),
  )

  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  use <- yuzu.false(player.is_observed(active_player), element.none())

  button.element([event.on_click(Undo)], [
    phosphor.arrow_arc_left_regular([]),
    html.text("Undo"),
  ])
}

fn end_turn_button_view(model: Model) {
  let engine = model.engine

  use <- yuzu.none(engine.loser, element.none())

  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  use <- yuzu.false(player.is_observed(active_player), element.none())

  button.element(
    [
      engine
        |> engine.validate_turn_request(model.turn_request)
        |> bool.negate()
        |> button.prop_disabled(),
      event.on_click(EndTurn),
    ],
    [html.text("End Turn")],
  )
}
