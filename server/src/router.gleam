import core/yuzu
import envoy
import gleam/bit_array
import gleam/bytes_tree
import gleam/crypto
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/string
import mist
import names.{type Names}
import router/api_router
import router/middleware
import router/ws_router

pub fn supervised(names: Names) {
  // TODO: For now, we generate a new `ID_COOKIE_SECRET` whenever the
  // application is restarted. This means that all previous cookies / sessions
  // will be invalidated.
  envoy.set(
    "ID_COOKIE_SECRET",
    crypto.strong_random_bytes(64)
      |> bit_array.base64_url_encode(False)
      |> string.slice(0, 64),
  )

  handler(names)
  |> mist.new()
  // TODO: Read this from env variables.
  // In particular, needs to be "0.0.0.0" when running inside docker.
  |> mist.bind("127.0.0.1")
  |> mist.port(8000)
  |> mist.supervised()
}

fn handler(names: Names) {
  fn(req: Request(mist.Connection)) {
    case request.path_segments(req) {
      ["api", ..subpath] -> api_router.handler(req, subpath)

      ["ws"] -> {
        use _ <- middleware.ensure_user_id(req)

        mist.websocket(
          request: req,
          on_init: ws_router.on_init(_, names),
          on_close: ws_router.on_close,
          handler: ws_router.handler,
        )
      }

      _ ->
        response.new(404)
        |> response.set_body(mist.Bytes(bytes_tree.new()))
    }
  }
}
