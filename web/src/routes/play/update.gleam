import lustre/effect
import routes/play/message.{type Message}
import routes/play/model.{type Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.EnterClassicMatchmaking -> #(model, effect.none())
    message.EnterDoublesMatchmaking -> #(model, effect.none())
    message.EnterStandardMatchmaking -> #(model, effect.none())
    message.CreateCustomLobby -> #(model, effect.none())
  }
}
