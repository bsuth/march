import engine/card.{type Card}
import engine/card/face.{type Face}
import engine/card/suit.{type Suit}
import engine/color.{type Color}
import lustre/attribute.{type Attribute}
import lustre/element/html
import phosphor

pub fn card_view(attrs: List(Attribute(message)), card: Card) {
  html.div(
    [
      attribute.class("flex flex-col justify-center items-center gap-1"),
      attribute.class("text-4xl font-bold"),
      attribute.class("select-none"),
      case card.suit, card.color {
        suit.Diamonds, _ -> attribute.class("text-red-400")
        suit.Hearts, _ -> attribute.class("text-red-400")
        _, color.Black -> attribute.class("text-white")
        _, color.White -> attribute.class("text-black")
      },
      case card.color {
        color.Black -> attribute.class("bg-black")
        color.White -> attribute.class("bg-white")
      },
      ..attrs
    ],
    [
      suit_view([attribute.class("size-4")], suit.strong(card.suit), card.color),
      html.div(
        [
          attribute.class("flex items-center gap-1"),
          attribute.class("text-4xl font-bold"),
        ],
        [
          face_view(card.face),
          suit_view([attribute.class("size-8")], card.suit, card.color),
        ],
      ),
      suit_view([attribute.class("size-4")], suit.weak(card.suit), card.color),
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
