import gleam/http/request
import mist
import names.{type Names}
import server/router/http_router
import server/router/ws_router
import wisp/wisp_mist

pub fn handler(secret_key_base: String, names: Names) {
  let http_handler = wisp_mist.handler(http_router.handler, secret_key_base)

  fn(req: request.Request(mist.Connection)) {
    case request.path_segments(req) {
      ["ws"] ->
        mist.websocket(
          request: req,
          on_init: ws_router.on_init(_, names),
          on_close: ws_router.on_close,
          handler: ws_router.handler,
        )

      _ -> http_handler(req)
    }
  }
}
