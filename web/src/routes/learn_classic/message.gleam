import core/engine/card.{type Card}
import core/engine/turn

pub type Message {
  Deploy(Card)
  OnUpdateTurnRequest(turn.Request)
  ResetTurnRequest
  ShuffleCards
  ToggleTableOfContents
}
