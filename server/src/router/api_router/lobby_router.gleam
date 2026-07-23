import actors/lobby
import api
import core/yuzu
import gleam/bytes_tree
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import gleam/otp/actor
import mist
import router/middleware

pub fn handler(req: Request(mist.Connection), path: List(String)) {
  case req.method, path {
    http.Post, [] -> post(req)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn post(req: Request(mist.Connection)) {
  // TODO: store as lobby owner
  use user_id <- middleware.ensure_user_id(req)

  use request_body <- middleware.json_body(
    req,
    api.post_lobby_request_decoder(),
  )

  let lobby_settings =
    lobby.Settings(name: request_body.name, public: request_body.public)

  use actor.Started(_, lobby_state) <- yuzu.ok(
    lobby.start(state.names, lobby_settings),
    response.new(500)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  let response_body =
    api.PostLobbyResponse(id: lobby_state.id)
    |> api.post_lobby_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()
  // TODO: api_lobby.create_response

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
