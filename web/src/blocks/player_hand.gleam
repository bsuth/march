import blocks/card as blocks_card
import core/engine/card.{type Card}
import core/engine/card_art.{type CardArt}
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

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn card_art(card_art: CardArt) {
  attribute.property("card_art", card_art.json(card_art))
}

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
    component.on_property_change("card_art", {
      card_art.decoder() |> decode.map(PropsChangedCardArt)
    }),
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
  Model(card_art: CardArt, class: String, player: Player, vertical: Bool)
}

fn init(_) {
  #(
    Model(
      card_art: card_art.DefaultBlack,
      class: "",
      player: player.Observed(0, 0, 0, []),
      vertical: False,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedCardArt(CardArt)
  PropsChangedClass(String)
  PropsChangedPlayer(Player)
  PropsChangedVertical(Bool)

  CardClick(Card)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedCardArt(card_art) -> #(Model(..model, card_art:), effect.none())
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
          attribute.class("h-full"),
          blocks_card.class("h-full cursor-pointer"),
          blocks_card.card_art(model.card_art),
          blocks_card.variant(blocks_card.Front(card.face, card.suit)),
          event.on_click(CardClick(card)),
        ])
      })

    player.Observed(_, _, hand, ..) ->
      int.range(0, hand, [], fn(children, _) {
        list.prepend(
          children,
          blocks_card.element([
            attribute.class("h-full"),
            blocks_card.class("h-full"),
            blocks_card.card_art(model.card_art),
            blocks_card.variant(blocks_card.Back),
          ]),
        )
      })
  }

  html.div(
    [
      attribute.class(model.class),
      attribute.class("h-28 flex gap-4"),
      case model.vertical {
        True -> attribute.class("flex-col")
        False -> attribute.none()
      },
    ],
    children,
  )
}
