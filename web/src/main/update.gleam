import gleam/json
import lib/websocket
import lustre/effect
import main/message.{type Message}
import main/model.{type Model, Model}
import main/websocket_update.{websocket_update}

pub fn update(model: Model, message: Message) {
  case message {
    // TODO: load lobby
    message.RouterChangedUri(uri) -> #(Model(..model, uri:), effect.none())
    message.RouterLoadedLobby(id) -> router_loaded_lobby(model, id)
    message.UserCreatedLobby -> user_created_lobby(model)
    message.WebsocketMessage(ws_msg) -> websocket_update(model, ws_msg)
  }
}

fn router_loaded_lobby(model: Model, id: String) {
  [
    #("method", json.string("get_lobby")),
    #("payload", json.string(id)),
  ]
  |> json.object()
  |> json.to_string()
  |> websocket.send(model.ws, _)

  #(model, effect.none())
}

fn user_created_lobby(model: Model) {
  [
    #("method", json.string("create_lobby")),
    #("payload", json.null()),
  ]
  |> json.object()
  |> json.to_string()
  |> websocket.send(model.ws, _)

  #(model, effect.none())
}
