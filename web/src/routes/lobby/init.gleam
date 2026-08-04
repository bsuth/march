import gleam/json
import gleam/option
import http_api/http_lobby
import lib/websocket
import main/app.{type App}
import routes/lobby/message
import routes/lobby/model.{Model}
import rsvp
import ws_api/ws_lobby

pub fn init(app: App, lobby_id: String) {
  ws_lobby.enter_json(lobby_id)
  |> json.to_string()
  |> websocket.send(app.ws, _)

  #(
    Model(app:, lobby_id:, lobby: option.None, edit_name: option.None),
    http_lobby.get_response_decoder()
      |> rsvp.expect_json(message.ApiLobbyGetResponse)
      |> rsvp.get("/api/lobby/" <> lobby_id, _),
  )
}
