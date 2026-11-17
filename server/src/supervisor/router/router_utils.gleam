import gleam/bytes_tree
import gleam/http/response
import gleam/json.{type Json}
import mist

pub fn json_response(payload: Json) {
  let body =
    payload
    |> json.to_string_tree()
    |> bytes_tree.from_string_tree()
    |> mist.Bytes()

  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(body)
}
