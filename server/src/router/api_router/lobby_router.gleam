import actors/lobby
import actors/lobby_registry
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import gleam/option
import gleam/otp/actor
import http_api/http_lobby
import ipc
import mist
import names.{type Names}
import router/middleware
import yuzu

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  case req.method, path {
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
    http_lobby.GetResponse(lobby)
    |> http_lobby.get_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}

fn post(names: Names, req: Request(mist.Connection)) {
  use user_id <- middleware.ensure_user_id(req)

  use request_body <- middleware.json_body(
    req,
    http_lobby.post_request_decoder(),
  )

  let lobby_settings =
    lobby.Settings(
      owner_user_id: user_id,
      black_user_id: option.None,
      white_user_id: option.None,
      name: request_body.name,
      is_public: request_body.is_public,
      variant: request_body.variant,
      board_width: request_body.board_width,
      board_height: request_body.board_height,
    )

  use actor.Started(_, lobby_state) <- yuzu.ok(
    lobby.start(names, lobby_settings),
    response.new(500)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  let response_body =
    http_lobby.PostResponse(lobby.entity(lobby_state))
    |> http_lobby.post_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
