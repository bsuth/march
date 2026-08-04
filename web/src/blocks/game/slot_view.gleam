import blocks/game/x
import engine/card
import engine/color.{type Color}
import engine/unit.{type Unit}
import gleam/option.{type Option}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor

pub fn unknown_slot_view(color: Color, attrs: List(Attribute(x.Msg))) {
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

pub fn unit_slot_view(
  unit: Unit,
  on_click_msg: Option(x.Msg),
  attrs: List(Attribute(x.Msg)),
) {
  clickable_slot_view(
    on_click_msg,
    [
      attribute.class("flex justify-center items-center"),
      attribute.class("text-4xl font-bold"),
      attribute.class("select-none"),
      case unit.card.suit, unit.color {
        card.Diamonds, _ -> attribute.class("text-red-400")
        card.Hearts, _ -> attribute.class("text-red-400")
        _, color.Black -> attribute.class("text-white")
        _, color.White -> attribute.class("text-black")
      },
      case unit.color {
        color.Black -> attribute.class("bg-black")
        color.White -> attribute.class("bg-white")
      },
      ..attrs
    ],
    [
      case unit.card.value {
        card.Jack -> html.text("J")
        card.Queen -> html.text("Q")
        card.King -> html.text("K")
        card.Ace -> html.text("A")
      },
      case unit.card.suit {
        card.Spades -> phosphor.spade_fill([attribute.class("size-8")])
        card.Diamonds -> phosphor.diamond_fill([attribute.class("size-8")])
        card.Clubs -> phosphor.club_fill([attribute.class("size-8")])
        card.Hearts -> phosphor.heart_fill([attribute.class("size-8")])
      },
    ],
  )
}

pub fn empty_slot_view(
  on_click_msg: Option(x.Msg),
  attrs: List(Attribute(x.Msg)),
) {
  clickable_slot_view(
    on_click_msg,
    [attribute.class("bg-gray-500"), ..attrs],
    [],
  )
}

pub fn clickable_slot_view(
  msg: Option(x.Msg),
  attrs: List(Attribute(x.Msg)),
  children: List(Element(x.Msg)),
) {
  slot_view(
    case msg {
      option.None -> attrs
      option.Some(msg) -> [
        attribute.class("cursor-pointer"),
        attribute.class("ring-4"),
        event.on_click(msg),
        case msg {
          x.Unhover | x.Undo ->
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
  attrs: List(Attribute(x.Msg)),
  children: List(Element(x.Msg)),
) {
  html.div(
    [
      attribute.class("size-24"),
      attribute.class("rounded overflow-hidden"),
      ..attrs
    ],
    children,
  )
}
