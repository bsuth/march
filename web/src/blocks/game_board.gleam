import blocks/board
import core/engine.{type Engine}
import core/engine/card
import core/engine/move
import core/engine/player
import core/engine/settings
import core/engine/turn
import core/util
import gleam/dict
import gleam/dynamic/decode
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
import lustre/event
import yuzu

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_engine(engine: Engine) {
  attribute.property("engine", engine.json(engine))
}

pub fn prop_flipped(flipped: Bool) {
  attribute.property("flipped", json.bool(flipped))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

pub fn prop_turn_request(turn_request: turn.Request) {
  attribute.property("turn_request", turn.request_json(turn_request))
}

pub fn on_update_turn_request(handler: fn(turn.Request) -> message) {
  event.on(
    "update_turn_request",
    ["detail"] |> decode.at(turn.request_decoder()) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-game-board"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("engine", {
      engine.decoder() |> decode.map(PropsChangedEngine)
    }),
    component.on_property_change("flipped", {
      decode.bool |> decode.map(PropsChangedFlipped)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(PropsChangedTheme)
    }),
    component.on_property_change("turn_request", {
      turn.request_decoder() |> decode.map(PropsChangedTurnRequest)
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
    theme: Theme,
    turn_request: turn.Request,
  )
}

fn init(_) {
  let settings = settings.classic()
  let kernel = engine.new_kernel(settings)
  let engine = engine.new(kernel)

  #(
    Model(
      engine:,
      flipped: False,
      hover_index: option.None,
      theme: theme.Light,
      turn_request: turn.Request(option.None, [], option.None),
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

pub type Message {
  PropsChangedEngine(Engine)
  PropsChangedFlipped(Bool)
  PropsChangedTheme(Theme)
  PropsChangedTurnRequest(turn.Request)

  OnCellClick(Int)
  OnFocusOut
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedEngine(engine) -> #(Model(..model, engine:), effect.none())
    PropsChangedFlipped(flipped) -> #(Model(..model, flipped:), effect.none())
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())
    PropsChangedTurnRequest(turn_request) -> #(
      Model(..model, turn_request:),
      effect.none(),
    )

    OnCellClick(click_index) -> update_on_cell_click(model, click_index)
    OnFocusOut -> #(Model(..model, hover_index: option.None), effect.none())
  }
}

fn update_on_cell_click(model: Model, click_index: Int) {
  use <- yuzu.none(model.engine.loser, #(model, effect.none()))

  use <- yuzu.false(
    model.engine.players
      |> util.get_list_index(model.engine.active_player_index)
      |> result.map(player.is_observed)
      |> result.unwrap(True),
    #(model, effect.none()),
  )

  let last_dest_index = case model.turn_request {
    turn.Request(_, _, option.Some(_)) ->
      settings.get_base_index(
        model.engine.kernel.settings,
        model.engine.active_player_index,
      )

    turn.Request(_, [_, index, ..], _) -> index
    turn.Request(option.Some(#(index, _)), [_], _) -> index
    turn.Request(option.Some(#(_, index)), _, _) -> index

    _ -> -1
  }

  use <- yuzu.false(click_index == last_dest_index, #(
    model,
    event.emit(
      "update_turn_request",
      model.turn_request |> turn.undo() |> turn.request_json(),
    ),
  ))

  case model.turn_request {
    turn.Request(_, _, option.Some(_)) -> #(model, effect.none())
    turn.Request(option.Some(lead), ..) ->
      update_on_cell_click_march(model, click_index, lead)
    _ -> update_on_cell_click_lead(model, click_index)
  }
}

fn update_on_cell_click_lead(model: Model, click_index: Int) {
  use <- yuzu.false(option.Some(click_index) == model.hover_index, #(
    Model(..model, hover_index: option.None),
    effect.none(),
  ))

  use click_cell <- yuzu.ok(dict.get(model.engine.position, click_index), #(
    model,
    effect.none(),
  ))

  case model.hover_index, click_cell {
    option.None, option.Some(click_card) -> {
      case click_card.player_index == model.engine.active_player_index {
        True -> #(
          Model(..model, hover_index: option.Some(click_index)),
          effect.none(),
        )
        False -> #(model, effect.none())
      }
    }

    option.Some(hover_index), option.None ->
      update_on_cell_click_lead_move(model, hover_index, click_index)

    option.Some(hover_index), option.Some(click_card) -> {
      use hover_card <- yuzu.some(
        model.engine.position
          |> dict.get(hover_index)
          |> result.unwrap(option.None),
        #(model, effect.none()),
      )

      use <- yuzu.false(hover_card.player_index == click_card.player_index, #(
        Model(..model, hover_index: option.Some(click_index)),
        effect.none(),
      ))

      use <- yuzu.true(card.can_capture(hover_card, click_card), #(
        Model(..model, hover_index: option.None),
        effect.none(),
      ))

      update_on_cell_click_lead_move(model, hover_index, click_index)
    }

    _, _ -> #(model, effect.none())
  }
}

fn update_on_cell_click_lead_move(
  model: Model,
  source_index: Int,
  dest_index: Int,
) {
  let valid_dest_indices =
    move.list_valid_dest_indices(
      source_index,
      model.engine.active_player_index,
      model.engine.position,
      model.engine.kernel.settings,
    )

  use <- yuzu.true(list.contains(valid_dest_indices, dest_index), #(
    Model(..model, hover_index: option.None),
    effect.none(),
  ))

  let lead = option.Some(#(source_index, dest_index))
  let turn_request = turn.Request(..model.turn_request, lead:)

  #(
    Model(..model, hover_index: option.None),
    event.emit("update_turn_request", turn.request_json(turn_request)),
  )
}

fn update_on_cell_click_march(
  model: Model,
  click_index: Int,
  lead: #(Int, Int),
) {
  use click_card <- yuzu.some(
    model.engine.position |> dict.get(click_index) |> result.unwrap(option.None),
    #(model, effect.none()),
  )

  use <- yuzu.true(
    click_card.player_index == model.engine.active_player_index,
    #(model, effect.none()),
  )

  use <- yuzu.false(
    model.turn_request.marches
      |> list.prepend(lead.1)
      |> list.prepend(lead.0)
      |> list.contains(click_index),
    #(model, effect.none()),
  )

  let dest_index = case model.turn_request.marches {
    [head, ..] -> head
    _ -> lead.0
  }

  use <- yuzu.true(
    move.is_march_index(
      click_index,
      dest_index,
      model.engine.active_player_index,
      model.engine.position,
      model.engine.kernel.settings,
    ),
    #(model, effect.none()),
  )

  use <- yuzu.true(
    click_index
      |> move.list_raw_dest_indices(
        model.engine.position,
        model.engine.kernel.settings,
      )
      |> list.contains(dest_index),
    #(model, effect.none()),
  )

  let marches = list.prepend(model.turn_request.marches, click_index)
  let turn_request = turn.Request(..model.turn_request, marches:)

  #(model, event.emit("update_turn_request", turn.request_json(turn_request)))
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  board.element([
    board.prop_flipped(model.flipped),
    board.prop_highlight_index(model.hover_index),
    board.prop_position(model.engine.position),
    board.prop_settings(model.engine.kernel.settings),
    board.prop_theme(model.theme),
    board.on_board_focusout(OnFocusOut),
    board.on_cell_click(OnCellClick),
  ])
}
