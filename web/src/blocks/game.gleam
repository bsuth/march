import blocks/board as ui_board
import blocks/card as ui_card
import components/button
import core/engine.{type Engine}
import core/engine/board
import core/engine/card.{type Card}
import core/engine/move
import core/engine/player
import core/engine/position
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

// TODO: refactor click code...
// TODO: prevent other players from controlling the board (introduce actor prop?)
// TODO: game history
// TODO: UI/UX improvements (hover_index indicator, drag cards, etc)

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

  BoardClick(Int)
  Deploy(Card)
  EndTurn
  Move(Int, Int)
  March(Int)
  Undo
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedEngine(engine) -> #(
      Model(
        ..model,
        engine:,
        turn_request: turn.Request(option.None, [], option.None),
        turn_request_engine: engine,
      ),
      effect.none(),
    )
    PropsChangedPlayerIndex(player_index) -> #(
      Model(..model, player_index:),
      effect.none(),
    )
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    BoardClick(index) -> update_board_click(model, index)
    Deploy(card) -> update_deploy(model, card)
    EndTurn -> update_end_turn(model)
    March(_index) -> #(model, effect.none())
    Move(_source_index, _dest_index) -> #(model, effect.none())
    Undo -> update_undo(model)
  }
}

fn update_board_click(model: Model, click_index: Int) {
  case model.turn_request {
    turn.Request(option.Some(lead), ..) ->
      update_board_click_march(model, click_index, lead)
    _ -> update_board_click_lead(model, click_index)
  }
}

fn update_board_click_lead(model: Model, click_index: Int) {
  use click_card <- yuzu.ok(
    dict.get(model.turn_request_engine.position, click_index),
    #(model, effect.none()),
  )

  case click_card, model.hover_index {
    option.None, option.None -> #(model, effect.none())

    option.Some(_), option.None -> #(
      Model(..model, hover_index: option.Some(click_index)),
      effect.none(),
    )

    option.None, option.Some(hover_index) -> {
      let valid_dest_indices =
        move.list_valid_dest_indices(
          hover_index,
          model.turn_request_engine.active_player_index,
          model.turn_request_engine.position,
          model.turn_request_engine.settings,
        )

      case list.contains(valid_dest_indices, click_index) {
        False -> #(Model(..model, hover_index: option.None), effect.none())
        True -> {
          let lead = option.Some(#(hover_index, click_index))
          let turn_request = turn.Request(..model.turn_request, lead:)
          let turn_request_engine =
            engine.preview_turn_request(model.engine, turn_request)

          #(
            Model(
              ..model,
              hover_index: option.None,
              turn_request:,
              turn_request_engine:,
            ),
            effect.none(),
          )
        }
      }
    }

    option.Some(click_card), option.Some(hover_index) -> {
      use hover_card <- yuzu.some(
        model.turn_request_engine.position
          |> dict.get(hover_index)
          |> result.unwrap(option.None),
        #(model, effect.none()),
      )

      let valid_dest_indices =
        move.list_valid_dest_indices(
          hover_index,
          model.turn_request_engine.active_player_index,
          model.turn_request_engine.position,
          model.turn_request_engine.settings,
        )

      let is_valid_lead =
        list.contains(valid_dest_indices, click_index)
        && card.can_capture(hover_card, click_card)

      let turn_request = case is_valid_lead {
        False -> model.turn_request
        True -> {
          let lead = option.Some(#(click_index, hover_index))
          turn.Request(..model.turn_request, lead:)
        }
      }

      #(Model(..model, hover_index: option.None, turn_request:), effect.none())
    }
  }
}

fn update_board_click_march(model: Model, click_index: Int, lead: #(Int, Int)) {
  let engine = model.turn_request_engine

  use click_card <- yuzu.ok(
    dict.get(model.turn_request_engine.position, click_index),
    #(model, effect.none()),
  )

  use click_card <- yuzu.some(click_card, #(model, effect.none()))

  let assert [dest_index, ..] =
    model.turn_request.marches
    |> list.prepend(lead.0)
    |> list.reverse()

  let is_valid_march =
    click_card.player_index == engine.active_player_index
    && move.is_march_index(
      click_index,
      dest_index,
      engine.active_player_index,
      engine.position,
      engine.settings,
    )
    && move.list_raw_dest_indices(click_index, engine.position, engine.settings)
    |> list.contains(dest_index)

  case is_valid_march {
    False -> #(model, effect.none())
    True -> {
      let marches = list.append(model.turn_request.marches, [click_index])
      let turn_request = turn.Request(..model.turn_request, marches:)
      let turn_request_engine =
        engine.preview_turn_request(model.engine, turn_request)
      #(Model(..model, turn_request:, turn_request_engine:), effect.none())
    }
  }
}

fn update_deploy(model: Model, card: Card) {
  let turn_request =
    turn.Request(..model.turn_request, deploy: option.Some(card))

  let turn_request_engine =
    engine.preview_turn_request(model.engine, turn_request)

  #(Model(..model, turn_request:, turn_request_engine:), effect.none())
}

fn update_end_turn(model: Model) {
  #(model, event.emit("turn_end", turn.request_json(model.turn_request)))
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
          player_hand_view(model, False, case engine.settings.doubles {
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
                  player_hand_view(model, True, { model.player_index + 1 } % 4)
              },
              ui_board.element([
                attribute.class("w-full h-full max-w-96 max-h-96"),
                ui_board.prop_player_index(model.player_index),
                ui_board.prop_position(engine.position),
                ui_board.prop_settings(engine.settings),
                ui_board.prop_theme(model.theme),
                ui_board.on_index_click(BoardClick),
              ]),
              case engine.settings.doubles {
                False -> element.none()
                True ->
                  player_hand_view(model, True, { model.player_index + 3 } % 4)
              },
            ],
          ),
          player_hand_view(model, False, model.player_index),
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

fn player_hand_view(model: Model, vertical: Bool, player_index: Int) {
  let engine = model.turn_request_engine

  let assert Ok(player) = util.get_list_index(engine.players, player_index)

  let player_color =
    player_color.from_player_index(player_index, engine.settings.doubles)

  let player_base_index = settings.get_base_index(engine.settings, player_index)

  let can_deploy = {
    use <- yuzu.true(engine.active_player_index == player_index, False)
    use <- yuzu.true(!player.has_empty_hand(player), False)
    position.is_none(engine.position, player_base_index)
    || option.is_some(model.turn_request.deploy)
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

fn end_turn_view(model: Model) {
  let engine = model.engine

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
