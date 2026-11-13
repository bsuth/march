import core/http_api/http_lobby
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import ipc
import mist
import names.{type Names}
import supervisor/router/middleware

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  case req.method, path {
    http.Get, [lobby_id] -> get(names, req, lobby_id)
    http.Post, [] -> post(names, req)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(names: Names, _req: Request(mist.Connection), lobby_id: String) {
  let lobby =
    names.lobby_manager
    |> process.named_subject()
    |> process.call_forever(fn(reply_subject) {
      ipc.LobbyManagerForward(lobby_id, ipc.LobbyGet(reply_subject))
    })

  let response_body =
    lobby
    |> http_lobby.get_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}

fn post(names: Names, req: Request(mist.Connection)) {
  use user <- middleware.ensure_user(req)

  let lobby_id =
    names.lobby_manager
    |> process.named_subject()
    |> process.call_forever(fn(reply_subject) {
      ipc.LobbyManagerNew(reply_subject, user.id)
    })

  let response_body =
    lobby_id
    |> http_lobby.post_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
