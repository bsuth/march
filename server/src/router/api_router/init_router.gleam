import api
import envoy
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
  let assert Ok(id_cookie_secret) = envoy.get("ID_COOKIE_SECRET")

  let id =
    request.get_cookies(req)
    |> list.find(fn(cookie) { cookie.0 == "id" })
    |> result.map(fn(cookie) {
      crypto.verify_signed_message(cookie.1, <<id_cookie_secret:utf8>>)
    })
    |> result.flatten()
    |> result.map(fn(user_id) { uuid.from_bit_array(user_id) })
    |> result.flatten()
    |> result.unwrap(uuid.v7())

  // TODO: add `type: User | Guest`
  let response_body =
    api.GetInitResponse(id: uuid.to_string(id))
    |> api.get_init_response_json()
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_cookie(
    "id",
    crypto.sign_message(
      uuid.to_bit_array(id),
      <<id_cookie_secret:utf8>>,
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
