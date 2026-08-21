import core/user.{User}
import envoy
import gleam/bit_array
import gleam/bytes_tree
import gleam/crypto
import gleam/http
import gleam/http/cookie
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import http_api/http_init
import mist
import youid/uuid

pub fn handler(req: Request(mist.Connection), path: List(String)) {
  case req.method, path {
    http.Get, [] -> get(req)

    _, _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}

fn get(req: Request(mist.Connection)) {
  let assert Ok(session_cookie_secret) = envoy.get("SESSION_COOKIE_SECRET")

  let user_id =
    request.get_cookies(req)
    |> list.find(fn(cookie) { cookie.0 == "session" })
    |> result.map(fn(cookie) {
      crypto.verify_signed_message(cookie.1, <<session_cookie_secret:utf8>>)
    })
    |> result.flatten()
    |> result.map(bit_array.to_string)
    |> result.flatten()
    |> result.map(fn(user_id) { uuid.from_string(user_id) })
    |> result.flatten()
    |> result.unwrap(uuid.v7())
    |> uuid.to_string()

  let response_body =
    // TODO: handle non-guest users
    User(user_id, "", True)
    |> http_init.get_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_cookie(
    "session",
    crypto.sign_message(
      <<user_id:utf8>>,
      <<session_cookie_secret:utf8>>,
      crypto.Sha512,
    ),
    cookie.Attributes(
      max_age: option.Some(365 * 24 * 60 * 60),
      domain: option.None,
      path: option.Some("/"),
      // TODO: make me secure in production
      secure: False,
      http_only: True,
      same_site: option.Some(cookie.Strict),
    ),
  )
  |> response.set_header("content-type", "application/json")
  |> response.set_body(response_body)
}
