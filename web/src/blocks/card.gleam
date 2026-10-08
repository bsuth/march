import engine/card.{type Card, Card}
import engine/face.{type Face}
import engine/suit.{type Suit}
import gleam/dynamic/decode
import lib/player_color.{type PlayerColor}
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
  attribute.property("card", card.json(card))
}

pub fn prop_player_color(player_color: PlayerColor) {
  attribute.property("player_color", player_color.json(player_color))
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
    component.on_property_change("card", {
      card.decoder() |> decode.map(PropsChangedCard)
    }),
    component.on_property_change("player_color", {
      player_color.decoder() |> decode.map(PropsChangedPlayerColor)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(card: Card, player_color: PlayerColor)
}

fn init(_) {
  #(
    Model(
      card: Card(face: face.Ace, suit: suit.Spades, player_index: 0),
      player_color: player_color.Black,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedCard(Card)
  PropsChangedPlayerColor(PlayerColor)
}

fn update(model: Model, msg: Message) {
  case msg {
    PropsChangedCard(card) -> #(Model(..model, card:), effect.none())
    PropsChangedPlayerColor(player_color) -> #(
      Model(..model, player_color:),
      effect.none(),
    )
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
      case model.card.suit, model.player_color {
        suit.Diamonds, _ -> attribute.class("text-red-400")
        suit.Hearts, _ -> attribute.class("text-red-400")
        _, player_color.White -> attribute.class("text-black")
        _, _ -> attribute.class("text-white")
      },
      case model.player_color {
        player_color.Black -> attribute.class("bg-black")
        player_color.White -> attribute.class("bg-white")
        player_color.LightRed -> attribute.class("bg-red-200")
        player_color.DarkRed -> attribute.class("bg-red-900")
      },
    ],
    [
      suit_view(
        [attribute.class("size-4")],
        suit.strong(model.card.suit),
        model.player_color,
      ),
      html.div(
        [
          attribute.class("flex items-center gap-1"),
          attribute.class("text-4xl font-bold"),
        ],
        [
          face_view(model.card.face),
          suit_view(
            [attribute.class("size-8")],
            model.card.suit,
            model.player_color,
          ),
        ],
      ),
      suit_view(
        [attribute.class("size-4")],
        suit.weak(model.card.suit),
        model.player_color,
      ),
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

fn suit_view(
  attrs: List(Attribute(message)),
  suit: Suit,
  player_color: PlayerColor,
) {
  let text_attribute = case suit, player_color {
    suit.Diamonds, _ -> attribute.class("text-red-400")
    suit.Hearts, _ -> attribute.class("text-red-400")
    _, player_color.Black -> attribute.class("text-white")
    _, _ -> attribute.class("text-black")
  }

  let icon = case suit {
    suit.Spades -> phosphor.spade_fill
    suit.Diamonds -> phosphor.diamond_fill
    suit.Clubs -> phosphor.club_fill
    suit.Hearts -> phosphor.heart_fill
  }

  icon([text_attribute, ..attrs])
}
