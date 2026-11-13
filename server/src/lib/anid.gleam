import gleam/int
import gleam/string

// A string of all possible characters that can appear in an ANID.
//
// We intentionally leave out `i`, `I`, `l`, `L`, `O`, and `0`, since they are
// often confused for one another.
const anid_chars = "abcdefghjkmnopqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ123456789"

// A precomputed value for `String.length(anid_chars)`.
const anid_chars_length = 56

pub fn random(length: Int) {
  int.range(0, length, "", fn(id, _) {
    string.slice(anid_chars, int.random(anid_chars_length), 1) <> id
  })
}
