import core/engine/turn
import core/match.{type Match}
import core/ws_api/ws_match
import gleam/json
import gleam/option
import lib/websocket
import lustre/effect
import routes/match/message.{type Message}
import routes/match/model.{type Model, Model}
import rsvp
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiMatchGetResponse(response) ->
      api_match_get_response(model, response)
    message.UserEndedTurn(turn_request) -> user_ended_turn(model, turn_request)
  }
}

fn api_match_get_response(
  model: Model,
  response: Result(Match, rsvp.Error(String)),
) {
  use match <- yuzu.ok(response, #(
    Model(..model, loading_match: False, match: option.None),
    effect.none(),
  ))

  ws_match.enter_json(match.id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(
    Model(..model, loading_match: False, match: option.Some(match)),
    effect.none(),
  )
}

fn user_ended_turn(model: Model, turn_request: turn.Request) {
  ws_match.request_turn_json(ws_match.RequestTurnPayload(
    model.match_id,
    turn_request,
  ))
  |> json.to_string()
  |> websocket.send(model.app.ws, _)

  #(model, effect.none())
}
