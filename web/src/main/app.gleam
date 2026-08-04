import lib/websocket.{type Websocket}

pub type App {
  App(user_id: String, ws: Websocket)
}
