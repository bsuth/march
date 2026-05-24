import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/x.{type Model, type Msg}

pub const title = "Moving Cards"

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.section(attrs, [
    html.h2([], [html.text(title)]),
    html.text(
      "Cards are moved one cell at a time and may be moved up, down, left, or
      right.",
    ),
    html.p([], [
      html.text("TODO: picture"),
    ]),
    html.text(
      "Whenever a player moves a card, they may choose to fill the original
      (now empty) cell by moving one of the cards directly below or to the right
      into the original cell. The player may repeat this action as long as cards
      are moved. Chaining card moves like this is referred to as \"marching\".",
    ),
    html.p([], [
      html.text("TODO: picture"),
    ]),
    html.text(
      "Cards may be moved into empty cells immediately, but may only be moved
      into non-empty cells if the other card can be captured. See the next
      chapter for more details on capturing cards.",
    ),
  ])
}
