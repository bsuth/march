import lustre/effect.{type Effect}

pub type Websocket

pub type WebsocketState {
  WebsocketConnecting
  WebsocketOpen
  WebsocketClosing
  WebsocketClosed
}

@external(javascript, "./websocket.js", "new_")
pub fn new(url: String) -> Websocket

pub fn state(ws: Websocket) -> WebsocketState {
  case state_(ws) {
    0 -> WebsocketConnecting
    1 -> WebsocketOpen
    2 -> WebsocketClosing
    _ -> WebsocketClosed
  }
}

@external(javascript, "./websocket.js", "state")
pub fn state_(ws: Websocket) -> Int

@external(javascript, "./websocket.js", "send")
pub fn send(ws: Websocket, data: String) -> Nil

pub fn on_open(ws: Websocket, callback: fn() -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) { on_open_(ws, fn() { callback() |> dispatch() }) })
}

@external(javascript, "./websocket.js", "on_open")
fn on_open_(ws: Websocket, callback: fn() -> Nil) -> Nil

pub fn on_message(ws: Websocket, callback: fn(String) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    on_message_(ws, fn(message) { callback(message) |> dispatch() })
  })
}

@external(javascript, "./websocket.js", "on_message")
fn on_message_(ws: Websocket, callback: fn(String) -> Nil) -> Nil

pub fn on_close(ws: Websocket, callback: fn(Int) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    on_close_(ws, fn(code) { code |> callback() |> dispatch() })
  })
}

@external(javascript, "./websocket.js", "on_close")
fn on_close_(ws: Websocket, callback: fn(Int) -> Nil) -> Nil
