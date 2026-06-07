import gleam/uri.{type Uri}
import lib/websocket.{type Websocket}

pub type Model {
  Model(uri: Uri, ws: Websocket)
}
