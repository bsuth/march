import core/engine/settings
import gleam/dynamic/decode
import gleam/option
import lustre/effect
import modem
import routes/play/message.{type Message}
import routes/play/model.{type Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyPostResponse(response) ->
      api_lobby_post_response(model, response)
    message.EnterClassicMatchmaking -> #(model, effect.none())
    message.EnterDoublesMatchmaking -> #(model, effect.none())
    message.EnterStandardMatchmaking -> #(model, effect.none())
    message.CreateCustomLobby -> #(model, effect.none())
    message.SubmitLobbyPostRequest -> submit_post_lobby_request(model)
  }
}

fn api_lobby_post_response(
  model: Model,
  response: Result(String, rsvp.Error(String)),
) {
  case response {
    Ok(lobby_id) -> #(
      model,
      modem.push("/lobby/" <> lobby_id, option.None, option.None),
    )
    Error(_) -> #(model, effect.none())
  }
}

fn submit_post_lobby_request(model: Model) {
  #(
    model,
    rsvp.post(
      "/api/lobby",
      // TODO: Allow adjusting settings
      settings.json(settings.standard()),
      rsvp.expect_json(decode.string, message.ApiLobbyPostResponse),
    ),
  )
}
