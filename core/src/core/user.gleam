import gleam/dynamic/decode
import gleam/json

pub type User {
  User(id: String, name: String, guest: Bool)
}

pub fn json(user: User) {
  json.object([
    #("id", json.string(user.id)),
    #("name", json.string(user.name)),
    #("guest", json.bool(user.guest)),
  ])
}

pub fn decoder() {
  use id <- decode.field("id", decode.string)
  use name <- decode.field("name", decode.string)
  use guest <- decode.field("guest", decode.bool)
  decode.success(User(id:, name:, guest:))
}
