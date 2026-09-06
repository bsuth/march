import blocks/card/message.{type Message}
import blocks/card/model.{type Model}
import lustre/effect

pub fn update(_model: Model, msg: Message) {
  case msg {
    message.PropsChangedCard(card) -> #(card, effect.none())
  }
}
