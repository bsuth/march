import api
import lustre/effect
import main/app.{type App}
import routes/home/model.{Model}

pub fn init(app: App) {
  let post_lobby_request = api.PostLobbyRequest(name: "", public: True)

  #(
    Model(app:, post_lobby_request:, post_lobby_request_loading: False),
    effect.none(),
  )
}
