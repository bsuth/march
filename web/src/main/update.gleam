import api
import gleam/option
import lib/websocket.{type Websocket}
import lustre/effect
import main/app.{type App, App}
import main/message.{type Message}
import main/model.{type Model, Model}
import main/websocket_update.{websocket_update}
import routes
import routes/home
import routes/learn
import rsvp

pub fn update(model: Model, message: Message) {
  case model, message {
    model.Home(_, route_model), message.Home(route_message) ->
      home.update(route_model, route_message)

    model.Learn(_, route_model), message.Learn(route_message) ->
      learn.update(route_model, route_message)

    _, message.ApiReturnedInit(result) -> api_returned_init(model, result)
    _, message.RouterChangedUri(uri) -> routes.init(model, uri)
    _, message.WebsocketClose -> websocket_close(model)
    _, message.WebsocketError -> websocket_error(model)
    _, message.WebsocketOpen(ws) -> websocket_open(model, ws)
    _, message.WebsocketMessage(ws_msg) -> websocket_update(model, ws_msg)

    _, _ -> {
      // TODO: log error
      #(model, effect.none())
    }
  }
}

fn update_model_app(model: Model, app: App) {
  case model {
    Model(_) -> Model(app)
    model.About(_) -> model.About(app)
    model.Home(_, route) -> model.Home(app, route)
    model.Learn(_, route) -> model.Learn(app, route)
    model.Lobby(_, route) -> model.Lobby(app, route)
    model.Versus(_) -> model.Versus(app)
  }
}

fn api_returned_init(
  model: Model,
  result: Result(api.GetInitResponse, rsvp.Error(String)),
) {
  case result {
    Ok(_response) -> {
      // TODO: store the response details
      #(
        model,
        websocket.connect(
          // TODO: Read this from env variables.
          // In particular, needs to be different when running inside docker.
          "ws://localhost:8000/ws",
          websocket.Events(
            on_close: option.Some(fn(_) { message.WebsocketClose }),
            on_error: option.Some(fn(_) { message.WebsocketError }),
            on_message: option.Some(fn(_, msg) { message.WebsocketMessage(msg) }),
            on_open: option.Some(message.WebsocketOpen),
          ),
        ),
      )
    }

    // TODO: handle error
    Error(_) -> #(model, effect.none())
  }
}

fn websocket_close(model: Model) {
  // TODO: reconnect
  #(update_model_app(model, App(ws: option.None)), effect.none())
}

fn websocket_error(model: Model) {
  // TODO: reconnect
  #(update_model_app(model, App(ws: option.None)), effect.none())
}

fn websocket_open(model: Model, ws: Websocket) {
  #(update_model_app(model, App(ws: option.Some(ws))), effect.none())
}
