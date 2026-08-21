import actors/lobby_registry
import core/lobby
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option
import ipc
import mist
import names.{type Names}

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  case req.method, path {
    http.Get, [] -> get(names, req)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(names: Names, _req: Request(mist.Connection)) {
  let response_body =
    lobby_registry.list(names)
    // TODO: REMOVE `call_forever`
    |> list.map(process.call_forever(_, ipc.LobbyGet))
    |> list.filter(fn(lobby) { lobby.visible && option.is_none(lobby.match_id) })
    |> json.array(lobby.json)
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
