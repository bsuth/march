import core/user.{type User}
import lib/theme
import lib/websocket
import lustre/effect
import main/app.{type App, App}
import main/message.{type Message}
import main/model.{type Model, Model}
import main/update_ws.{update_ws}
import routes
import routes/home
import routes/learn
import routes/lobby
import routes/match
import rsvp

pub fn update(model: Model, message: Message) {
  case model, message {
    model.Home(route_model), message.Home(route_message) ->
      home.update(route_model, route_message)

    model.Learn(route_model), message.Learn(route_message) ->
      learn.update(route_model, route_message)

    model.Lobby(route_model), message.Lobby(route_message) ->
      lobby.update(route_model, route_message)

    model.Match(route_model), message.Match(route_message) ->
      match.update(route_model, route_message)

    _, message.ApiInitGetResponse(result) ->
      api_init_get_response(model, result)
    _, message.RouterChangedUri(uri) -> routes.init(model, uri)
    _, message.ToggleTheme -> toggle_theme(model)
    _, message.WebsocketClose -> websocket_close(model)
    _, message.WebsocketError -> websocket_error(model)
    _, message.WebsocketOpen -> websocket_open(model)
    _, message.WebsocketMessage(ws_message) -> update_ws(model, ws_message)

    _, _ -> {
      // TODO: log error
      #(model, effect.none())
    }
  }
}

fn update_app(model: Model, app: App) {
  case model {
    Model(_) -> Model(app)
    model.About(_) -> model.About(app)
    model.Home(route) -> model.Home(home.update_app(route, app))
    model.Learn(route) -> model.Learn(learn.update_app(route, app))
    model.Lobby(route) -> model.Lobby(lobby.update_app(route, app))
    model.Match(route) -> model.Match(match.update_app(route, app))
  }
}

fn api_init_get_response(
  model: Model,
  result: Result(User, rsvp.Error(String)),
) {
  case result {
    Ok(user) -> {
      let app = model.get_app(model)
      websocket.connect(app.ws)
      #(update_app(model, App(..app, user:)), effect.none())
    }

    // TODO: handle error
    Error(_) -> #(model, effect.none())
  }
}

fn toggle_theme(model: Model) {
  let app = model.get_app(model)

  let theme = case app.theme {
    theme.Light -> theme.Dark
    theme.Dark -> theme.Light
  }

  theme.apply(theme)
  theme.save(theme)

  #(update_app(model, App(..app, theme:)), effect.none())
}

fn websocket_close(model: Model) {
  // TODO: notify user
  #(model, effect.none())
}

fn websocket_error(model: Model) {
  // TODO: notify user
  #(model, effect.none())
}

fn websocket_open(model: Model) {
  // TODO: reinit page
  #(model, effect.none())
}
