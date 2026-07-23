import api
import lustre/effect
import routes/home/message.{type Message}
import routes/home/model.{type Model, Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiPostLobbyResponse(response) ->
      api_post_lobby_response(model, response)

    message.SubmitPostLobbyRequest -> submit_post_lobby_request(model)

    message.UpdatePostLobbyRequest(post_lobby_request) -> #(
      Model(..model, post_lobby_request:),
      effect.none(),
    )
  }
}

fn api_post_lobby_response(
  model: Model,
  _response: Result(api.PostLobbyResponse, rsvp.Error(String)),
) {
  // TODO: navigate to lobby page
  #(Model(..model, post_lobby_request_loading: False), effect.none())
}

fn submit_post_lobby_request(model: Model) {
  #(
    Model(..model, post_lobby_request_loading: True),
    rsvp.post(
      "/api/lobby",
      api.post_lobby_request_json(model.post_lobby_request),
      api.post_lobby_response_decoder()
        |> rsvp.expect_json(message.ApiPostLobbyResponse),
    ),
  )
}
