import core/user.{type User}

// -----------------------------------------------------------------------------
// GET
// -----------------------------------------------------------------------------

pub fn get_response_json(user: User) {
  user.json(user)
}

pub fn get_response_decoder() {
  user.decoder()
}
