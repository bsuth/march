import core/engine
import core/engine/settings as engine_settings
import lustre/effect
import main/app.{type App}
import routes/home/bindings
import routes/home/message
import routes/home/model.{type Model, Model}

pub fn init(app: App) {
  let hero_engine =
    engine_settings.classic()
    |> engine.new_kernel()
    |> engine.new()

  #(
    Model(
      app:,
      hero_engine:,
      hero_engine_timeout: 0,
      post_lobby_request_loading: False,
    ),
    effect.from(fn(dispatch) {
      fn() { dispatch(message.HeroEngineResolveTimeout) }
      |> bindings.set_timeout(1000)
      |> message.HeroEngineSetTimeout()
      |> dispatch
    }),
  )
}

pub fn deinit(model: Model) {
  bindings.clear_timeout(model.hero_engine_timeout)
}
