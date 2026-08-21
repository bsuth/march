import core/user.{type User}
import lib/theme.{type Theme}
import lib/websocket.{type Websocket}

pub type App {
  App(theme: Theme, user: User, ws: Websocket)
}
