import actors/matchmaker
import gleam/erlang/process
import gleam/http/request
import mist.{type WebsocketConnection}
import router/http_router
import router/ws_router
import wisp/wisp_mist

pub fn handler(
  secret_key_base: String,
  matchmaker_subject: process.Subject(matchmaker.Message),
) {
  let http_handler = wisp_mist.handler(http_router.handler, secret_key_base)

  fn(req: request.Request(mist.Connection)) {
    case request.path_segments(req) {
      ["ws"] ->
        mist.websocket(
          request: req,
          on_init: fn(conn: WebsocketConnection) {
            ws_router.on_init(conn, matchmaker_subject)
          },
          on_close: ws_router.on_close,
          handler: ws_router.handler,
        )

      _ -> http_handler(req)
    }
  }
}
