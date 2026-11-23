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

pub type Variant {
  Front(face: Face, suit: Suit)
  Back
  Base
}

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn card_art(card_art: CardArt) {
  attribute.property("card_art", card_art.json(card_art))
}

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn variant(variant: Variant) {
  attribute.property("variant", case variant {
    Front(face, suit) ->
      json.object([#("face", face.json(face)), #("suit", suit.json(suit))])
    Back -> json.string("back")
    Base -> json.string("base")
  })
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
    component.on_property_change("variant", {
      {
        use face <- decode.field("face", face.decoder())
        use suit <- decode.field("suit", suit.decoder())
        decode.success(Front(face:, suit:))
      }
      |> decode.one_of([
        decode.then(decode.string, fn(variant_string) {
          case variant_string {
            "back" -> decode.success(Back)
            "base" -> decode.success(Base)
            _ -> decode.failure(Back, "variant")
          }
        }),
      ])
      |> decode.map(PropsChangedVariant)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(card_art: CardArt, class: String, variant: Variant)
}

fn init(_) {
  #(
    Model(card_art: card_art.DefaultBlack, class: "", variant: Back),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedCardArt(CardArt)
  PropsChangedClass(String)
  PropsChangedVariant(Variant)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedCardArt(card_art) -> #(Model(..model, card_art:), effect.none())
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedVariant(variant) -> #(Model(..model, variant:), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let basename = case model.variant {
    Front(face:, suit:) -> face.to_string(face) <> suit.to_string(suit)
    Back -> "back"
    Base -> "base"
  }

  let src =
    string.concat([
      "/decks",
      "/",
      card_art.to_string(model.card_art),
      "/",
      basename,
      ".png",
    ])

  html.img([
    attribute.class(model.class),
    attribute.class("w-full h-full object-contain"),
    attribute.src(src),
    attribute.alt(basename),
  ])
}
