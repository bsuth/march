import envoy
import exception
import gleam/bit_array
import gleam/bytes_tree
import gleam/crypto
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/list
import gleam/string
import logging
import mist
import yuzu

pub fn json_body(
  req: Request(mist.Connection),
  decoder: Decoder(value),
  handler: fn(value) -> Response(mist.ResponseData),
) {
  let empty_body = mist.Bytes(bytes_tree.new())

  use request_body <- yuzu.ok(
    // TODO: remove magic number
    mist.read_body(req, 1024 * 1024 * 10),
    response.new(413) |> response.set_body(empty_body),
  )

  use body <- yuzu.ok(
    json.parse_bits(request_body.body, decoder),
    response.new(400) |> response.set_body(empty_body),
  )

  handler(body)
}

pub fn ensure_user_id(
  req: Request(mist.Connection),
  handler: fn(String) -> Response(mist.ResponseData),
) {
  let assert Ok(session_cookie_secret) = envoy.get("SESSION_COOKIE_SECRET")

  let bad_request =
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  use unverified_session_cookie <- yuzu.ok(
    list.find(request.get_cookies(req), fn(cookie) { cookie.0 == "session" }),
    bad_request,
  )

  use session_bit_array <- yuzu.ok(
    crypto.verify_signed_message(unverified_session_cookie.1, <<
      session_cookie_secret:utf8,
    >>),
    bad_request,
  )

  case bit_array.to_string(session_bit_array) {
    Ok(user_id) -> handler(user_id)
    Error(_) -> bad_request
  }
}

pub fn log_request(
  req: Request(mist.Connection),
  handler: fn() -> Response(mist.ResponseData),
) {
  let response = handler()

  [
    int.to_string(response.status),
    " ",
    string.uppercase(http.method_to_string(req.method)),
    " ",
    req.path,
  ]
  |> string.concat()
  |> logging.log(logging.Info, _)

  response
}

pub fn rescue_crashes(handler: fn() -> Response(mist.ResponseData)) {
  case exception.rescue(handler) {
    Ok(response) -> response
    Error(error) -> {
      logging.log(logging.Error, string.inspect(error))
      response.new(500)
      |> response.set_header("content-type", "text/plain")
      |> response.set_body(mist.Bytes(bytes_tree.new()))
    }
  }
}
