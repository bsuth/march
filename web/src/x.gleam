import lib/websocket.{type WebSocket}
import routes.{type Route}

pub type Msg {
  OnRouteChange(Route)
  UserClickedTest
  Pong
  Matched
  WebsocketError(String)
}

pub type Model {
  Model(route: Route, ws: WebSocket)
}
