import engine/card.{Card}
import engine/card/face
import engine/card/suit
import engine/color
import lustre/effect

pub fn init() {
  #(
    Card(face: face.Ace, suit: suit.Spades, color: color.Black, traits: []),
    effect.none(),
  )
}
