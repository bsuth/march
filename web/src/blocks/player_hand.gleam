import blocks/card as ui_card
import core/engine/card.{type Card}
import core/engine/player.{type Player}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import phosphor

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_player(player: Player) {
  attribute.property("player", player.json(player))
}

pub fn prop_vertical(vertical: Bool) {
  attribute.property("vertical", json.bool(vertical))
}

pub fn on_card_click(handler: fn(Card) -> message) {
  event.on(
    "card_click",
    ["detail"] |> decode.at(card.decoder()) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-player-hand"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("player", {
      player.decoder() |> decode.map(PropsChangedPlayer)
    }),
    component.on_property_change("vertical", {
      decode.bool |> decode.map(PropsChangedVertical)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(player: Player, vertical: Bool)
}

fn init(_) {
  #(Model(player: player.Observed(0, 0, 0, []), vertical: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedPlayer(Player)
  PropsChangedVertical(Bool)

  CardClick(Card)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedPlayer(player) -> #(Model(..model, player:), effect.none())
    PropsChangedVertical(vertical) -> #(
      Model(..model, vertical:),
      effect.none(),
    )

    CardClick(card) -> #(model, event.emit("card_click", card.json(card)))
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let children = case model.player {
    player.Managed(_, _, hand, _) | player.Controlled(_, _, hand, _) ->
      list.map(hand, fn(card) {
        ui_card.element([
          ui_card.prop_card(card),
          attribute.class("cursor-pointer"),
          event.on_click(CardClick(card)),
        ])
      })

    player.Observed(_, _, hand, _) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_card_view())
      })
  }

  html.div(
    [
      attribute.class("flex gap-4"),
      case model.vertical {
        True -> attribute.class("flex-col")
        False -> attribute.none()
      },
    ],
    list.map(children, fn(child) {
      html.div([attribute.class("w-24 h-24 rounded overflow-hidden")], [
        child,
      ])
    }),
  )
}

fn unknown_card_view() {
  let suit_class = attribute.class("size-6 -rotate-45")

  html.div(
    [
      attribute.class("h-full flex justify-center items-center"),
      // TODO: properly load deck back
      attribute.class("text-white bg-black"),
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
