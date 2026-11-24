import lustre/effect
import routes/learn/message.{type Message}
import routes/learn/model.{type Model}

pub fn update(model: Model, _message: Message) {
  #(model, effect.none())
}
