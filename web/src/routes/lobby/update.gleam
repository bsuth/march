import lustre/effect
import routes/lobby/message.{type Message}
import routes/lobby/model.{type Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.BackendReceivedChat -> #(model, effect.none())
  }
}
