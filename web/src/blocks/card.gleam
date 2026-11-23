import core/engine/card_art.{type CardArt}
import core/engine/face.{type Face}
import core/engine/suit.{type Suit}
import gleam/dynamic/decode
import gleam/json
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn card_art(card_art: CardArt) {
  attribute.property("card_art", card_art.json(card_art))
}

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn face(face: Face) {
  attribute.property("face", face.json(face))
}

pub fn suit(suit: Suit) {
  attribute.property("suit", suit.json(suit))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-card"

pub fn element(attrs: List(Attribute(msg))) {
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
    component.on_property_change("face", {
      face.decoder() |> decode.map(PropsChangedFace)
    }),
    component.on_property_change("suit", {
      suit.decoder() |> decode.map(PropsChangedSuit)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(card_art: CardArt, class: String, face: Face, suit: Suit)
}

fn init(_) {
  #(
    Model(
      card_art: card_art.DefaultBlack,
      class: "",
      face: face.Ace,
      suit: suit.Spades,
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
  PropsChangedFace(Face)
  PropsChangedSuit(Suit)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedCardArt(card_art) -> #(Model(..model, card_art:), effect.none())
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedFace(face) -> #(Model(..model, face:), effect.none())
    PropsChangedSuit(suit) -> #(Model(..model, suit:), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let src =
    string.concat([
      "/decks",
      "/",
      card_art.to_string(model.card_art),
      "/",
      face.to_string(model.face),
      suit.to_string(model.suit),
      ".png",
    ])

  html.img([
    attribute.class(model.class),
    attribute.class("w-full h-full object-contain"),
    attribute.src(src),
    attribute.alt(face.to_string(model.face) <> suit.to_string(model.suit)),
  ])
}
