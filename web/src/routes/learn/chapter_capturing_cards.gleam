import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/x.{type Model, type Msg}

pub const title = "Capturing Cards"

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.section(attrs, [
    html.h2([], [html.text(title)]),
    html.text(
      "A player may only move a card into a non-empty cell if the other card
      can be captured.",
    ),
    html.text("If the cards have the same suit "),
    html.b([], [html.text("color")]),
    html.text(", the other card may only be captured if it has a value "),
    html.i([], [html.text("less than or equal")]),
    html.text(" to the player's card."),
    html.p([], [
      html.text("TODO: value rank"),
    ]),
    html.p([], [
      html.text("TODO: examples"),
    ]),
    html.text(
      "If the cards have differing suit colors, then the suits alone determine
      whether the card can be captured. Each suit is strong against one of the
      suits of the opposite color, and weak against the other:",
    ),
    html.p([], [
      html.text("TODO: suit graph"),
    ]),
    html.p([], [
      html.text("TODO: examples"),
    ]),
    html.text(
      "Players may always capture their own cards, regardless of the value and
      suit of either card. This is known as a “self-capture”.",
    ),
    html.p([], [
      html.text("TODO: example of self capture"),
    ]),
    html.text(
      "Since player's must move a card each turn (if possible), in rare
      circumstances a player may find themselves forced to self-capture:",
    ),
    html.p([], [
      html.text("TODO: example of forced self capture"),
    ]),
    html.text(
      "When a card is captured, it is removed from play and placed face down on
      the side. Players may not look back at captured cards.",
    ),
  ])
}
