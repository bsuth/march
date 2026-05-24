import gleam/http/request
import gleam/http/response
import mist
import router/http_router
import router/ws_router
import wisp/wisp_mist

pub fn handler(
  secret_key_base: String,
) -> fn(request.Request(mist.Connection)) ->
  response.Response(mist.ResponseData) {
  let http_handler = wisp_mist.handler(http_router.handler, secret_key_base)

  fn(req: request.Request(mist.Connection)) {
    case request.path_segments(req) {
      ["ws"] ->
        mist.websocket(
          request: req,
          on_init: ws_router.on_init,
          on_close: ws_router.on_close,
          handler: ws_router.handler,
        )

      _ -> http_handler(req)
    }
  }
}
