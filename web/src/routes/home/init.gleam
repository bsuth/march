import engine/variant
import http_api/http_lobby
import lustre/effect
import main/app.{type App}
import routes/home/model.{Model}

pub fn init(app: App) {
  let post_lobby_request =
    http_lobby.PostRequest(
      name: "",
      is_public: True,
      variant: variant.Standard,
      board_width: 4,
      board_height: 4,
    )

  #(
    Model(app:, post_lobby_request:, post_lobby_request_loading: False),
    effect.none(),
  )
}
