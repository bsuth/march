import engine/settings
import http_api/http_lobby
import http_api/http_lobby_list
import main/app.{type App}
import routes/home/message
import routes/home/model.{type Model, Model}
import rsvp

pub fn init(app: App) {
  let post_lobby_request =
    http_lobby.PostRequest(
      engine_settings: settings.classic(),
      name: "",
      visible: True,
    )

  #(
    Model(
      app:,
      lobbies: [],
      get_lobby_list_loading: True,
      post_lobby_request:,
      post_lobby_request_loading: False,
    ),
    http_lobby_list.get_response_decoder()
      |> rsvp.expect_json(message.ApiLobbyListGetResponse)
      |> rsvp.get("/api/lobby/list", _),
  )
}

pub fn deinit(_model: Model) {
  Nil
}
