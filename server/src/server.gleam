import mist
import names.{type Names}
import server/router
import wisp

pub fn supervised(names: Names) {
  // TODO: For now, we generate a new `secret_key_base` whenever the application
  // is restarted. This means that all previous cookies / sessions will be
  // invalidated.
  let secret_key_base = wisp.random_string(64)

  router.handler(secret_key_base, names)
  |> mist.new()
  |> mist.port(8000)
  |> mist.supervised()
}
