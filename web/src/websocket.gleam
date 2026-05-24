import lustre/effect.{type Effect}

pub type WebSocket

pub type WebSocketState {
  WebSocketConnecting
  WebSocketOpen
  WebSocketClosing
  WebSocketClosed
}

@external(javascript, "./websocket.js", "create")
pub fn create(url: String) -> WebSocket

@external(javascript, "./websocket.js", "state")
pub fn raw_state(ws: WebSocket) -> Int

pub fn state(ws: WebSocket) -> WebSocketState {
  case raw_state(ws) {
    0 -> WebSocketConnecting
    1 -> WebSocketOpen
    2 -> WebSocketClosing
    _ -> WebSocketClosed
  }
}

@external(javascript, "./websocket.js", "send")
pub fn send(ws: WebSocket, data: String) -> Nil

@external(javascript, "./websocket.js", "close")
pub fn close(ws: WebSocket) -> Nil

@external(javascript, "./websocket.js", "on_open")
fn raw_on_open(ws: WebSocket, callback: fn() -> Nil) -> Nil

pub fn on_open(ws: WebSocket, callback: fn() -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    raw_on_open(ws, fn() { callback() |> dispatch() })
  })
}

@external(javascript, "./websocket.js", "on_message")
fn raw_on_message(ws: WebSocket, callback: fn(String) -> Nil) -> Nil

pub fn on_message(ws: WebSocket, callback: fn(String) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    raw_on_message(ws, fn(data) { data |> callback() |> dispatch() })
  })
}

@external(javascript, "./websocket.js", "on_close")
fn raw_on_close(ws: WebSocket, callback: fn(Int) -> Nil) -> Nil

pub fn on_close(ws: WebSocket, callback: fn(Int) -> msg) -> Effect(msg) {
  effect.from(fn(dispatch) {
    raw_on_close(ws, fn(code) { code |> callback() |> dispatch() })
  })
}
