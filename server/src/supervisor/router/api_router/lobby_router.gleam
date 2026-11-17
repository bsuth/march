import core/engine/settings
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/json
import ipc
import mist
import names.{type Names}
import supervisor/router/middleware
import supervisor/router/router_utils

pub fn post(names: Names, req: Request(mist.Connection)) {
  use user <- middleware.ensure_user(req)
  use engine_settings <- middleware.json_body(req, settings.decoder())

  names.lobby_manager
  |> process.named_subject()
  |> process.call_forever(fn(reply_subject) {
    ipc.LobbyManagerNew(
      reply_subject:,
      owner_user_id: user.id,
      engine_settings:,
    )
  })
  |> json.string()
  |> router_utils.json_response()
}
