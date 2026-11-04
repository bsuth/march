import core/engine/face.{type Face}
import core/engine/settings.{type Settings}
import core/engine/suit.{type Suit}
import core/engine/turn.{type Turn}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/string
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

pub fn prop_settings(settings: Settings) {
  attribute.property("settings", settings.json(settings))
}

pub fn prop_turns(turns: List(Turn)) {
  attribute.property("turns", json.array(turns, turn.json))
}

pub fn on_turn_click(handler: fn(Int) -> message) -> Attribute(message) {
  event.on(
    "turn_click",
    ["detail"] |> decode.at(decode.int) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-game-history"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("settings", {
      settings.decoder() |> decode.map(PropsChangedSettings)
    }),
    component.on_property_change("turns", {
      decode.list(turn.decoder()) |> decode.map(PropsChangedTurns)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(settings: Settings, turns: List(Turn))
}

fn init(_) {
  #(Model(settings: settings.standard(), turns: []), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedSettings(Settings)
  PropsChangedTurns(List(Turn))
  OnTurnClick(Int)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedSettings(settings) -> #(
      Model(..model, settings:),
      effect.none(),
    )
    PropsChangedTurns(turns) -> #(Model(..model, turns:), effect.none())

    OnTurnClick(turn_index) -> #(
      model,
      event.emit("turn_click", json.int(turn_index)),
    )
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let num_players = case model.settings.doubles {
    True -> 4
    False -> 2
  }

  html.ul(
    [attribute.class("flex flex-col overflow-auto")],
    list.flatten([
      model.turns
        |> list.reverse()
        |> list.index_map(fn(turn, turn_index) {
          turn_view(turn, turn_index, num_players)
        }),
      model.turns
        |> list.reverse()
        |> list.index_map(fn(turn, turn_index) {
          turn_view(turn, turn_index, num_players)
        }),
      model.turns
        |> list.reverse()
        |> list.index_map(fn(turn, turn_index) {
          turn_view(turn, turn_index, num_players)
        }),
      model.turns
        |> list.reverse()
        |> list.index_map(fn(turn, turn_index) {
          turn_view(turn, turn_index, num_players)
        }),
    ]),
  )
}

fn turn_view(turn: Turn, turn_index: Int, num_players: Int) {
  let player_turn_index = turn_index / num_players
  let player_index = turn_index % num_players

  html.li(
    [
      attribute.class("p-2"),
      attribute.class("flex items-center gap-2"),
      attribute.class("cursor-pointer hover:bg-(--march-200)"),
      event.on_click(OnTurnClick(turn_index)),
    ],
    [
      [int.to_string(player_turn_index + 1), int.to_string(player_index + 1)]
        |> string.join(".")
        |> html.text()
        |> fn(text_node) { html.p([attribute.class("mr-auto")], [text_node]) },
      turn_capture_view(turn),
      turn_moves_view(turn),
      turn_deploy_view(turn),
      turn_draw_view(turn),
    ],
  )
}

fn turn_capture_view(turn: Turn) {
  use card <- yuzu.some(turn.capture, element.none())

  html.div(
    [
      attribute.title("Lead"),
      attribute.class("flex items-center gap-1"),
    ],
    [phosphor.sword_regular([]), turn_card_view(card.face, card.suit)],
  )
}

fn turn_moves_view(turn: Turn) {
  use _ <- yuzu.some(turn.lead, element.none())

  html.div(
    [
      attribute.title("Moves"),
      attribute.class("flex items-center gap-1"),
    ],
    [
      phosphor.line_segment_regular([]),
      list.length(turn.marches) + 1 |> int.to_string() |> html.text(),
    ],
  )
}

fn turn_deploy_view(turn: Turn) {
  use card <- yuzu.some(turn.deploy, element.none())

  html.div(
    [
      attribute.title("Deploy"),
      attribute.class("flex items-center gap-1"),
    ],
    [
      phosphor.castle_turret_regular([]),
      turn_card_view(card.face, card.suit),
    ],
  )
}

fn turn_draw_view(turn: Turn) {
  use <- yuzu.true(
    case turn {
      turn.Controlled(_, _, _, _, _, option.Some(_)) -> True
      turn.Observed(_, _, _, _, _, True) -> True
      _ -> False
    },
    element.none(),
  )

  html.div(
    [
      attribute.title("Draw"),
      attribute.class("flex items-center gap-1"),
    ],
    [
      phosphor.hand_regular([]),
      case turn {
        turn.Controlled(_, _, _, _, _, option.Some(card)) ->
          turn_card_view(card.face, card.suit)
        turn.Observed(_, _, _, _, _, True) ->
          1 |> int.to_string() |> html.text()
        _ -> element.none()
      },
    ],
  )
}

fn turn_card_view(face: Face, suit: Suit) {
  html.div(
    [
      attribute.class("flex items-center"),
      case suit {
        suit.Diamonds | suit.Hearts ->
          attribute.class("text-(--march-suit-red)")
        _ -> attribute.none()
      },
    ],
    [
      case face {
        face.Jack -> html.text("J")
        face.Queen -> html.text("Q")
        face.King -> html.text("K")
        face.Ace -> html.text("A")
      },
      case suit {
        suit.Spades -> phosphor.spade_fill([])
        suit.Diamonds -> phosphor.diamond_fill([])
        suit.Clubs -> phosphor.club_fill([])
        suit.Hearts -> phosphor.heart_fill([])
      },
    ],
  )
}
