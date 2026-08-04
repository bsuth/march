import gleam/option
import http_api/http_lobby
import lustre/effect
import modem
import routes/home/message.{type Message}
import routes/home/model.{type Model, Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyPostResponse(response) ->
      api_post_lobby_response(model, response)

    message.SubmitLobbyPostRequest -> submit_post_lobby_request(model)

    message.UpdateLobbyPostRequest(post_lobby_request) -> #(
      Model(..model, post_lobby_request:),
      effect.none(),
    )
  }
}

fn api_post_lobby_response(
  model: Model,
  response: Result(http_lobby.PostResponse, rsvp.Error(String)),
) {
  case response {
    Ok(response) -> {
      #(
        Model(..model, post_lobby_request_loading: False),
        modem.push("/lobby/" <> response.lobby.id, option.None, option.None),
      )
    }

    Error(_) -> {
      // TODO: show error
      #(Model(..model, post_lobby_request_loading: False), effect.none())
    }
  }
}

fn submit_post_lobby_request(model: Model) {
  #(
    Model(..model, post_lobby_request_loading: True),
    rsvp.post(
      "/api/lobby",
      http_lobby.post_request_json(model.post_lobby_request),
      http_lobby.post_response_decoder()
        |> rsvp.expect_json(message.ApiLobbyPostResponse),
    ),
  )
}
