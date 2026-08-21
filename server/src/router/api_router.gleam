import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response
import mist
import names.{type Names}
import router/api_router/init_router
import router/api_router/lobby_router
import router/api_router/match_router
import router/middleware

pub fn handler(
  names: Names,
  req: Request(mist.Connection),
  path: List(String),
) {
  use <- middleware.rescue_crashes()
  use <- middleware.log_request(req)

  // TODO
  // use _ <- middleware.csrf_known_header_protection(req)

  case path {
    ["init", ..subpath] -> init_router.handler(req, subpath)
    ["lobby", ..subpath] -> lobby_router.handler(names, req, subpath)
    ["match", ..subpath] -> match_router.handler(names, req, subpath)

    _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
