import actors/lobby
import actors/lobby_registry
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import gleam/otp/actor
import http_api/http_lobby
import ipc
import mist
import names.{type Names}
import router/api_router/lobby_router/list_router
import router/middleware
import yuzu

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  case req.method, path {
    _, ["list", ..subpath] -> list_router.handler(names, req, subpath)

    http.Get, [id] -> get(names, req, id)
    http.Post, [] -> post(names, req)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(names: Names, _req: Request(mist.Connection), id: String) {
  use lobby_subject <- yuzu.ok(
    lobby_registry.get(names, id),
    response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  let lobby = process.call_forever(lobby_subject, ipc.LobbyGet)

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

  use request_body <- middleware.json_body(
    req,
    http_lobby.post_request_decoder(),
  )

  let init_args =
    lobby.StartArgs(
      board_height: request_body.board_height,
      board_width: request_body.board_width,
      name: request_body.name,
      owner: user,
      variant: request_body.variant,
      visible: request_body.visible,
    )

  use actor.Started(_, lobby_actor_state) <- yuzu.ok(
    lobby.start(names, init_args),
    response.new(500)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  let response_body =
    lobby_actor_state.lobby
    |> http_lobby.post_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
