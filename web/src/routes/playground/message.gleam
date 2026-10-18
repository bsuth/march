import core/engine/turn

pub type Message {
  CommitTurn(turn.Request)
}
