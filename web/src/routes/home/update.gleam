import core/lobby.{type Lobby}
import gleam/option
import http_api/http_lobby
import http_api/http_lobby_list
import lustre/effect
import modem
import routes/home/message.{type Message}
import routes/home/model.{type Model, Model}
import rsvp

pub fn update(model: Model, message: Message) {
  case message {
    message.ApiLobbyListGetResponse(response) ->
      api_lobby_list_get_response(model, response)

    message.ApiLobbyPostResponse(response) ->
      api_lobby_post_response(model, response)

    message.SubmitLobbyPostRequest -> submit_post_lobby_request(model)

    message.UpdateLobbyPostRequest(post_lobby_request) -> #(
      Model(..model, post_lobby_request:),
      effect.none(),
    )

    message.UserClickedLobby(lobby) -> #(
      model,
      modem.push("/lobby/" <> lobby.id, option.None, option.None),
    )

    message.UserRefreshedLobbyList -> #(
      Model(..model, get_lobby_list_loading: True),
      http_lobby_list.get_response_decoder()
        |> rsvp.expect_json(message.ApiLobbyListGetResponse)
        |> rsvp.get("/api/lobby/list", _),
    )
  }
}

fn api_lobby_list_get_response(
  model: Model,
  response: Result(List(Lobby), rsvp.Error(String)),
) {
  case response {
    Ok(lobbies) -> {
      #(Model(..model, lobbies:, get_lobby_list_loading: False), effect.none())
    }

    Error(_) -> {
      // TODO: show error
      #(Model(..model, get_lobby_list_loading: False), effect.none())
    }
  }
}

fn api_lobby_post_response(
  model: Model,
  response: Result(Lobby, rsvp.Error(String)),
) {
  case response {
    Ok(lobby) -> {
      #(
        Model(..model, post_lobby_request_loading: False),
        modem.push("/lobby/" <> lobby.id, option.None, option.None),
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
