import blocks/game/message.{type Message}
import engine/card.{type Card}
import engine/card/face
import engine/card/suit
import engine/color.{type Color}
import gleam/option.{type Option}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor

pub fn unknown_slot_view(color: Color, attrs: List(Attribute(Message))) {
  let suit_class = attribute.class("size-6 -rotate-45")

  slot_view(
    [
      attribute.class("flex justify-center items-center"),
      case color {
        color.Black -> attribute.class("text-white bg-black")
        color.White -> attribute.class("text-black bg-white")
      },
      ..attrs
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

pub fn card_slot_view(
  card: Card,
  on_click_msg: Option(Message),
  attrs: List(Attribute(Message)),
) {
  clickable_slot_view(
    on_click_msg,
    [
      attribute.class("flex justify-center items-center"),
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
      case card.face {
        face.Jack -> html.text("J")
        face.Queen -> html.text("Q")
        face.King -> html.text("K")
        face.Ace -> html.text("A")
      },
      case card.suit {
        suit.Spades -> phosphor.spade_fill([attribute.class("size-8")])
        suit.Diamonds -> phosphor.diamond_fill([attribute.class("size-8")])
        suit.Clubs -> phosphor.club_fill([attribute.class("size-8")])
        suit.Hearts -> phosphor.heart_fill([attribute.class("size-8")])
      },
    ],
  )
}

pub fn empty_slot_view(
  on_click_msg: Option(Message),
  attrs: List(Attribute(Message)),
) {
  clickable_slot_view(
    on_click_msg,
    [attribute.class("border border-zinc-50"), ..attrs],
    [],
  )
}

pub fn clickable_slot_view(
  on_click_msg: Option(Message),
  attrs: List(Attribute(Message)),
  children: List(Element(Message)),
) {
  slot_view(
    case on_click_msg {
      option.None -> attrs
      option.Some(on_click_msg) -> [
        attribute.class("cursor-pointer"),
        event.on_click(on_click_msg),
        case on_click_msg {
          message.Unhover | message.Undo ->
            attribute.class("ring-red-600/50 hover:ring-red-600")
          _ -> attribute.class("ring-green-400/50 hover:ring-green-400")
        },
        ..attrs
      ]
    },
    children,
  )
}

pub fn slot_view(
  attrs: List(Attribute(Message)),
  children: List(Element(Message)),
) {
  html.div([attribute.class("size-24"), ..attrs], children)
}
