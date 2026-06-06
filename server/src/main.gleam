import actors/matchmaker
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import router/router
import wisp

pub fn main() {
  wisp.configure_logger()

  // For now, we generate a new `` whenever our application is restarted. Note
  // that this means that all previous cookies / sessions will be invalidated.
  let secret_key_base = wisp.random_string(64)

  let assert Ok(matchmaker_actor) = matchmaker.start()

  let port =
    envoy.get("PORT")
    |> result.try(int.parse)
    |> result.unwrap(8000)

  let assert Ok(_) =
    router.handler(secret_key_base, matchmaker_actor.data)
    |> mist.new()
    |> mist.port(port)
    |> mist.start()

  // The web server runs in a new Erlang process, so we can just put this one to
  // sleep forever.
  process.sleep_forever()
}
