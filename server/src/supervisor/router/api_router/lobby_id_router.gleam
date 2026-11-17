import core/lobby
import gleam/erlang/process
import gleam/http/request.{type Request}
import ipc
import mist
import names.{type Names}
import supervisor/router/router_utils

pub fn get(names: Names, _req: Request(mist.Connection), lobby_id: String) {
  names.lobby_manager
  |> process.named_subject()
  |> process.call_forever(fn(reply_subject) {
    ipc.LobbyManagerForward(lobby_id:, message: ipc.LobbyGet(reply_subject:))
  })
  |> lobby.json()
  |> router_utils.json_response()
}
