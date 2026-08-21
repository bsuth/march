import core/match.{type Match}
import engine/color
import gleam/json
import gleam/option
import lib/websocket
import lustre/effect
import routes/match/message.{type Message}
import routes/match/model.{type Model, Model}
import rsvp
import ws_api/ws_match
import yuzu

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiMatchGetResponse(response) ->
      api_match_get_response(model, response)
    message.UserEndedTurn -> #(model, effect.none())
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

  let color = case match.white.id {
    _ if model.app.user.id == match.white.id -> color.White
    _ -> color.Black
  }

  #(
    Model(..model, color:, loading_match: False, match: option.Some(match)),
    effect.none(),
  )
}
