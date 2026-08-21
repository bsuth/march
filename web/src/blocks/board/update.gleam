import blocks/board/message.{type Message}
import blocks/board/model.{type Model, Model}
import lustre/effect

pub fn update(model: Model, msg: Message) {
  case msg {
    message.PropsChangedBoard(board) -> #(Model(..model, board:), effect.none())
    message.PropsChangedColor(color) -> #(Model(..model, color:), effect.none())
    message.PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())
  }
}
