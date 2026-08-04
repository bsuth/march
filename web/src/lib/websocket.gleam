import gleam/json
import lustre/effect

pub type Websocket

pub fn init(
  url: String,
  on_open: fn() -> message,
  on_message: fn(String) -> message,
  on_close: fn() -> message,
  on_error: fn() -> message,
) {
  let ws = new_(url)

  #(
    ws,
    effect.batch([
      effect.from(fn(dispatch) {
        on_open_(ws, fn() { on_open() |> dispatch() })
      }),
      effect.from(fn(dispatch) {
        on_message_(ws, fn(msg) { on_message(msg) |> dispatch() })
      }),
      effect.from(fn(dispatch) {
        on_close_(ws, fn() { on_close() |> dispatch() })
      }),
      effect.from(fn(dispatch) {
        on_error_(ws, fn() { on_error() |> dispatch() })
      }),
    ]),
  )
}

@external(javascript, "./websocket.js", "connect")
pub fn connect(ws: Websocket) -> Nil

@external(javascript, "./websocket.js", "send")
pub fn send(ws: Websocket, data: String) -> Nil

pub fn json(ws: Websocket, data: json.Json) {
  data
  |> json.to_string()
  |> send(ws, _)
}

@external(javascript, "./websocket.js", "new_")
fn new_(url: String) -> Websocket

@external(javascript, "./websocket.js", "on_open")
fn on_open_(ws: Websocket, callback: fn() -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_message")
fn on_message_(ws: Websocket, callback: fn(String) -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_close")
fn on_close_(ws: Websocket, callback: fn() -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_error")
fn on_error_(ws: Websocket, callback: fn() -> Nil) -> Nil
