import engine/color
import gleam/json
import gleam/option
import http_api/http_match
import lib/websocket
import main/app.{type App}
import routes/match/message
import routes/match/model.{type Model, Model}
import rsvp
import ws_api/ws_match

pub fn init(app: App, match_id: String) {
  #(
    Model(
      app:,
      color: color.Black,
      loading_match: True,
      match: option.None,
      match_id:,
    ),
    http_match.get_response_decoder()
      |> rsvp.expect_json(message.ApiMatchGetResponse)
      |> rsvp.get("/api/match/" <> match_id, _),
  )
}

pub fn deinit(model: Model) {
  ws_match.exit_json(model.match_id)
  |> json.to_string()
  |> websocket.send(model.app.ws, _)
}
