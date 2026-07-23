import gleam/option.{type Option}
import lib/websocket.{type Websocket}

pub type App {
  App(ws: Option(Websocket))
}
