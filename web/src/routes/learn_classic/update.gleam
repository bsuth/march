import core/engine
import core/engine/card.{type Card}
import core/engine/turn
import gleam/bool
import gleam/dict
import gleam/option
import gleam/result
import lustre/effect
import routes/learn_classic/chapter
import routes/learn_classic/message.{type Message}
import routes/learn_classic/model.{type Model, Model}
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.Deploy(card) -> deploy(model, card)
    message.OnUpdateTurnRequest(turn_request) ->
      on_update_turn_request(model, turn_request)
    message.ResetTurnRequest -> reset_turn_request(model)
    message.ShuffleCards -> shuffle_cards(model)
    message.ToggleTableOfContents -> #(
      Model(..model, show_table_of_contents: !model.show_table_of_contents),
      effect.none(),
    )
  }
}

fn deploy(model: Model, card: Card) {
  use <- yuzu.true(
    model.turn_request_engine.position
      |> dict.get(0)
      |> result.unwrap(option.None)
      |> option.is_none()
      |> bool.or(option.is_some(model.turn_request.deploy)),
    #(model, effect.none()),
  )

  let turn_request =
    turn.Request(..model.turn_request, deploy: option.Some(card))

  #(
    Model(
      ..model,
      turn_request:,
      turn_request_engine: engine.preview_turn_request(
        model.engine,
        turn_request,
      ),
    ),
    effect.none(),
  )
}

fn on_update_turn_request(model: Model, turn_request: turn.Request) {
  #(
    Model(
      ..model,
      turn_request:,
      turn_request_engine: engine.preview_turn_request(
        model.engine,
        turn_request,
      ),
    ),
    effect.none(),
  )
}

fn reset_turn_request(model: Model) {
  #(
    Model(
      ..model,
      turn_request: turn.Request(option.None, [], option.None),
      turn_request_engine: model.engine,
    ),
    effect.none(),
  )
}

fn shuffle_cards(model: Model) {
  let engine = chapter.engine(model.chapter)

  #(
    Model(
      ..model,
      engine:,
      turn_request: turn.Request(option.None, [], option.None),
      turn_request_engine: engine,
    ),
    effect.none(),
  )
}
