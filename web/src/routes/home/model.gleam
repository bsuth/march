import core/lobby.{type Lobby}
import http_api/http_lobby
import main/app.{type App}

pub type Model {
  Model(
    app: App,
    lobbies: List(Lobby),
    get_lobby_list_loading: Bool,
    post_lobby_request: http_lobby.PostRequest,
    post_lobby_request_loading: Bool,
  )
}
