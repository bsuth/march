import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/string
import group_registry
import names.{type Names}

// A string of all possible characters that can appear in a lobby ID.
//
// IMPORTANT: If this is updated, `id_chars_length` will also need to be
// updated below.
const id_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

// A precomputed value for `String.length(id_chars)`.
const id_chars_length = 62

// The length of each generated ID.
const id_length = 8

// How many unique IDs we try to generate before we give up.
const max_id_attempts = 5

pub fn supervised(names: Names) {
  group_registry.supervised(names.lobby_registry)
}

pub fn generate_id() {
  int.range(0, id_length, "", fn(id, _) {
    string.slice(id_chars, int.random(id_chars_length), 1) <> id
  })
}

pub fn register_self(names: Names) {
  let self = process.self()
  let registry = group_registry.get_registry(names.lobby_registry)

  let lobby_id_result =
    list.repeat(0, max_id_attempts)
    |> list.map(fn(_) { generate_id() })
    |> list.find(fn(lobby_id) {
      case group_registry.members(registry, lobby_id) {
        [_] -> False
        _ -> True
      }
    })

  case lobby_id_result {
    Ok(lobby_id) -> {
      let subject = group_registry.join(registry, lobby_id, self)
      Ok(#(lobby_id, subject))
    }

    _ -> Error(Nil)
  }
}

pub fn get(names: Names, lobby_id: String) {
  let registry = group_registry.get_registry(names.lobby_registry)

  case group_registry.members(registry, lobby_id) {
    [subject] -> Ok(subject)
    _ -> Error(Nil)
  }
}
