import actors/match_registry
import core/match
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import http_api/http_match
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

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(names: Names, req: Request(mist.Connection), id: String) {
  use user <- middleware.ensure_user(req)

  use match_subject <- yuzu.ok(
    match_registry.get(names, id),
    response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  use match <- yuzu.ok(
    process.call_forever(match_subject, ipc.MatchGet)
      |> match.mask_players(user),
    response.new(500)
      |> response.set_body(mist.Bytes(bytes_tree.new())),
  )

  let response_body =
    match
    |> http_match.get_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
