import routes.{type Route}
import websocket.{type WebSocket}

pub type Msg {
  OnRouteChange(Route)
  UserClickedTest
}

pub type Model {
  Model(route: Route, ws: WebSocket)
}
