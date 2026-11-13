import main/app.{type App}

pub type Model {
  Model(app: App, post_lobby_request_loading: Bool)
}
