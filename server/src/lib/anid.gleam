import gleam/int
import gleam/string

// A string of all possible characters that can appear in an ANID.
const anid_chars = "abcdefghijklmnopqrstuvwxyz0123456789"

// A precomputed value for `String.length(anid_chars)`.
const anid_chars_length = 36

pub fn generate(length: Int) {
  int.range(0, length, "", fn(id, _) {
    string.slice(anid_chars, int.random(anid_chars_length), 1) <> id
  })
}
