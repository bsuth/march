import gleam/json
import gleam/option.{type Option}
import lustre/effect

pub type Websocket

pub type Events(message) {
  Events(
    on_open: Option(fn(Websocket) -> message),
    on_message: Option(fn(Websocket, String) -> message),
    on_close: Option(fn(Websocket) -> message),
    on_error: Option(fn(Websocket) -> message),
  )
}

pub fn connect(url: String, events: Events(message)) {
  let ws = new(url)

  effect.batch([
    case events.on_open {
      option.None -> effect.none()
      option.Some(callback) ->
        effect.from(fn(dispatch) {
          on_open(ws, fn() { callback(ws) |> dispatch() })
        })
    },
    case events.on_message {
      option.None -> effect.none()
      option.Some(callback) ->
        effect.from(fn(dispatch) {
          on_message(ws, fn(msg) { callback(ws, msg) |> dispatch() })
        })
    },
    case events.on_close {
      option.None -> effect.none()
      option.Some(callback) ->
        effect.from(fn(dispatch) {
          on_close(ws, fn() { callback(ws) |> dispatch() })
        })
    },
    case events.on_error {
      option.None -> effect.none()
      option.Some(callback) ->
        effect.from(fn(dispatch) {
          on_error(ws, fn() { callback(ws) |> dispatch() })
        })
    },
  ])
}

@external(javascript, "./websocket.js", "send")
pub fn send(ws: Websocket, data: String) -> Nil

pub fn json(ws: Websocket, data: json.Json) {
  data
  |> json.to_string()
  |> send(ws, _)
}

@external(javascript, "./websocket.js", "new_")
fn new(url: String) -> Websocket

@external(javascript, "./websocket.js", "on_open")
fn on_open(ws: Websocket, callback: fn() -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_message")
fn on_message(ws: Websocket, callback: fn(String) -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_close")
fn on_close(ws: Websocket, callback: fn() -> Nil) -> Nil

@external(javascript, "./websocket.js", "on_error")
fn on_error(ws: Websocket, callback: fn() -> Nil) -> Nil
