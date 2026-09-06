import blocks/game/message.{type Message}
import blocks/game/model.{type Model, Model}
import engine.{Engine}
import gleam/option
import lustre/effect
import yuzu

pub fn update(model: Model, msg: Message) {
  case msg {
    message.PropsChangedColor(color) -> #(Model(..model, color:), effect.none())

    message.PropsChangedEngine(engine) -> #(
      Model(..model, engine:),
      effect.none(),
    )

    message.PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    message.Unhover -> #(
      Model(..model, hover_index: option.None),
      effect.none(),
    )

    message.Hover(index) -> #(
      Model(..model, hover_index: option.Some(index)),
      effect.none(),
    )

    message.Move(_source_index, _dest_index) -> {
      echo "move"
      // TODO
      #(model, effect.none())
    }

    message.March(_index) -> {
      echo "march"
      // TODO
      #(model, effect.none())
    }

    message.Deploy(card) -> {
      use engine <- yuzu.ok(engine.deploy(model.engine, option.Some(card)), #(
        model,
        effect.none(),
      ))

      #(Model(..model, engine:), effect.none())
    }

    message.Pass -> {
      // TODO
      #(model, effect.none())
    }

    message.Undo -> {
      // TODO
      #(model, effect.none())
    }
  }
}
