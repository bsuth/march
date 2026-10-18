import core/engine
import core/match.{Match}
import core/ws_api
import core/ws_api/ws_match
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option
import lustre/effect
import routes/match/model.{type Model, Model}
import yuzu

pub fn update_ws(model: Model, ws_message: ws_api.Message) {
  case ws_message.path {
    "match.turn_ended" -> turn_ended(model, ws_message.payload)
    _ -> #(model, effect.none())
  }
}

fn turn_ended(model: Model, payload: Dynamic) {
  use payload <- yuzu.ok(decode.run(payload, ws_match.turn_ended_decoder()), #(
    model,
    effect.none(),
  ))

  use match <- yuzu.some(model.match, #(model, effect.none()))
  use <- yuzu.true(match.id == payload.match_id, #(model, effect.none()))

  let engine = engine.commit_turn(match.engine, payload.turn)
  let match = Match(..match, engine:)

  #(Model(..model, match: option.Some(match)), effect.none())
}
