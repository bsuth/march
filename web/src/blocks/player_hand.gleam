import blocks/card as blocks_card
import core/engine/card.{type Card}
import core/engine/card_art
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

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn player(player: Player) {
  attribute.property("player", player.json(player))
}

pub fn vertical(vertical: Bool) {
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
    component.on_property_change("class", {
      decode.string |> decode.map(PropsChangedClass)
    }),
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
  Model(class: String, player: Player, vertical: Bool)
}

fn init(_) {
  #(
    Model(
      class: "",
      player: player.Observed(0, 0, 0, [], card_art.DefaultBlack),
      vertical: False,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedPlayer(Player)
  PropsChangedVertical(Bool)

  CardClick(Card)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
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
    player.Managed(_, _, hand, ..) | player.Controlled(_, _, hand, ..) ->
      list.map(hand, fn(card) {
        blocks_card.element([
          blocks_card.card_art(model.player.card_art),
          blocks_card.face(card.face),
          blocks_card.suit(card.suit),
          attribute.class("cursor-pointer"),
          event.on_click(CardClick(card)),
        ])
      })

    player.Observed(_, _, hand, ..) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(children, unknown_card_view())
      })
  }

  html.div(
    [
      attribute.class(model.class),
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
