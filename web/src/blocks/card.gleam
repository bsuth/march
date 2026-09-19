import engine/card.{type Card, Card}
import engine/card/face.{type Face}
import engine/card/suit.{type Suit}
import engine/color.{type Color}
import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import phosphor

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_value(card: Card) {
  attribute.property("value", card.json(card))
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
    component.on_property_change("value", {
      card.decoder() |> decode.map(PropsChangedCard)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model =
  Card

fn init(_) {
  #(
    Card(face: face.Ace, suit: suit.Spades, color: color.Black, traits: []),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedCard(Card)
}

fn update(_model: Model, msg: Message) {
  case msg {
    PropsChangedCard(card) -> #(card, effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.div(
    [
      attribute.class("w-full h-full"),
      attribute.class("flex flex-col justify-center items-center gap-1"),
      attribute.class("text-4xl font-bold"),
      attribute.class("select-none"),
      case model.suit, model.color {
        suit.Diamonds, _ -> attribute.class("text-red-400")
        suit.Hearts, _ -> attribute.class("text-red-400")
        _, color.Black -> attribute.class("text-white")
        _, color.White -> attribute.class("text-black")
      },
      case model.color {
        color.Black -> attribute.class("bg-black")
        color.White -> attribute.class("bg-white")
      },
    ],
    [
      suit_view(
        [attribute.class("size-4")],
        suit.strong(model.suit),
        model.color,
      ),
      html.div(
        [
          attribute.class("flex items-center gap-1"),
          attribute.class("text-4xl font-bold"),
        ],
        [
          face_view(model.face),
          suit_view([attribute.class("size-8")], model.suit, model.color),
        ],
      ),
      suit_view([attribute.class("size-4")], suit.weak(model.suit), model.color),
    ],
  )
}

fn face_view(face: Face) {
  case face {
    face.Jack -> html.text("J")
    face.Queen -> html.text("Q")
    face.King -> html.text("K")
    face.Ace -> html.text("A")
  }
}

fn suit_view(attrs: List(Attribute(message)), suit: Suit, color: Color) {
  let text_attribute = case suit, color {
    suit.Diamonds, _ -> attribute.class("text-red-400")
    suit.Hearts, _ -> attribute.class("text-red-400")
    _, color.Black -> attribute.class("text-white")
    _, color.White -> attribute.class("text-black")
  }

  let icon = case suit {
    suit.Spades -> phosphor.spade_fill
    suit.Diamonds -> phosphor.diamond_fill
    suit.Clubs -> phosphor.club_fill
    suit.Hearts -> phosphor.heart_fill
  }

  icon([text_attribute, ..attrs])
}
