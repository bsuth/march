import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import routes/learn/x.{type Model, type Msg}

pub const title = "Gameplay"

pub fn view(_model: Model, attrs: List(Attribute(Msg))) -> Element(Msg) {
  html.section(attrs, [
    html.h2([], [html.text(title)]),
    html.text(
      "Players alternate taking turns until the game is over, with each player’s
      turn consisting of the following steps:",
    ),
    html.ol([], [
      html.li([], [
        html.text(
          "The player must move a card. If it is not possible to move a card
          (ex. on each player's first turn), this step is skipped.",
        ),
      ]),
      html.li([], [
        html.text(
          "If there is no card on the player’s base, the player must play a card
          from their hand onto their base. If the player has no cards in hand,
          this step is skipped.",
        ),
      ]),
      html.li([], [
        html.text(
          "The player draws until they have four cards in their hand. If the
          player's deck is empty, this step is skipped.",
        ),
      ]),
    ]),
    html.text(
      "A player wins once they move one of their cards onto the enemy base.",
    ),
  ])
}
