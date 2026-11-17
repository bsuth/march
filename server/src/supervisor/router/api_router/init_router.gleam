import core/user.{User}
import envoy
import gleam/bit_array
import gleam/crypto
import gleam/http/cookie
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option
import gleam/result
import mist
import supervisor/router/router_utils
import youid/uuid

pub fn get(req: Request(mist.Connection)) {
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

  User(user_id, "", True)
  |> user.json()
  |> router_utils.json_response()
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
}
