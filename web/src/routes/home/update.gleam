import core/http_api/http_lobby
import gleam/option
import lustre/effect
import modem
import routes/home/message.{type Message}
import routes/home/model.{type Model, Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyPostResponse(response) ->
      api_lobby_post_response(model, response)

    message.SubmitLobbyPostRequest -> submit_post_lobby_request(model)
  }
}

fn api_lobby_post_response(
  model: Model,
  response: Result(String, rsvp.Error(String)),
) {
  case response {
    Ok(lobby_id) -> {
      #(
        Model(..model, post_lobby_request_loading: False),
        modem.push("/lobby/" <> lobby_id, option.None, option.None),
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
      http_lobby.post_request_json(),
      rsvp.expect_json(
        http_lobby.post_response_decoder(),
        message.ApiLobbyPostResponse,
      ),
    ),
  )
}
