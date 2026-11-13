import core/http_api/http_match
import core/match
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
    http.Get, [id] -> get(names, req, id)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(names: Names, req: Request(mist.Connection), match_id: String) {
  use user <- middleware.ensure_user(req)

  let match =
    names.match_manager
    |> process.named_subject()
    |> process.call_forever(fn(reply) {
      ipc.MatchManagerForward(match_id, ipc.MatchGet(reply))
    })

  let response_body =
    match.mask(match, user)
    |> http_match.get_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
