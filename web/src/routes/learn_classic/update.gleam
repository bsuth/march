import lustre/effect
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model, Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.ToggleTableOfContents -> #(
      Model(..model, show_table_of_contents: !model.show_table_of_contents),
      effect.none(),
    )
  }
}
