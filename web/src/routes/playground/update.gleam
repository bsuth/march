import core/engine
import core/engine/turn
import gleam/result
import lustre/effect
import routes/playground/message.{type Message}
import routes/playground/model.{type Model, Model}

pub fn update(model: Model, message: Message) {
  case message {
    message.CommitTurn(turn_request) -> update_commit_turn(model, turn_request)
  }
}

fn update_commit_turn(model: Model, turn_request: turn.Request) {
  let engine =
    model.engine
    |> engine.commit_turn_request(turn_request)
    |> result.unwrap(model.engine)

  #(Model(..model, engine:), effect.none())
}
