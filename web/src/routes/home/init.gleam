import lustre/effect
import main/app.{type App}
import routes/home/model.{type Model, Model}

pub fn init(app: App) {
  #(Model(app:, post_lobby_request_loading: False), effect.none())
}

pub fn deinit(_model: Model) {
  Nil
}
