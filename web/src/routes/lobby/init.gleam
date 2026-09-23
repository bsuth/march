import gleam/json
import gleam/option
import http_api/http_lobby
import lib/websocket
import main/app.{type App}
import routes/lobby/message
import routes/lobby/model.{type Model, Model}
import rsvp
import ws_api/ws_lobby

pub fn init(app: App, lobby_id: String) {
  #(
    Model(
      app:,
      edit_name: option.None,
      lobby: option.None,
      lobby_id:,
      lobby_loading: True,
    ),
    http_lobby.get_response_decoder()
      |> rsvp.expect_json(message.ApiLobbyGetResponse)
      |> rsvp.get("/api/lobby/" <> lobby_id, _),
  )
}

pub fn deinit(model: Model) {
  ws_lobby.exit_json(model.lobby_id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)
}
