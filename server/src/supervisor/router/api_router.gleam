import gleam/bytes_tree
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import mist
import names.{type Names}
import supervisor/router/api_router/init_router
import supervisor/router/api_router/lobby_id_router
import supervisor/router/api_router/lobby_router
import supervisor/router/api_router/match_router
import supervisor/router/middleware

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  use <- middleware.rescue_crashes()
  use <- middleware.log_request(req)

  // TODO
  // use _ <- middleware.csrf_known_header_protection(req)

  case path, req.method {
    ["init"], http.Get -> init_router.get(req)

    ["lobby"], http.Post -> lobby_router.post(names, req)
    ["lobby", lobby_id], http.Get -> lobby_id_router.get(names, req, lobby_id)

    ["match", match_id], http.Get -> match_router.get(names, req, match_id)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
