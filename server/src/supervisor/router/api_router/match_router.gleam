import core/match
import gleam/erlang/process
import gleam/http/request.{type Request}
import ipc
import mist
import names.{type Names}
import supervisor/router/middleware
import supervisor/router/router_utils

pub fn get(names: Names, req: Request(mist.Connection), match_id: String) {
  use user <- middleware.ensure_user(req)

  names.match_manager
  |> process.named_subject()
  |> process.call_forever(fn(reply) {
    ipc.MatchManagerForward(match_id:, message: ipc.MatchGet(reply))
  })
  |> match.mask(user)
  |> match.json()
  |> router_utils.json_response()
}
