import gleam/dynamic/decode
import gleam/json

pub type Suit {
  Spades
  Diamonds
  Clubs
  Hearts
}

pub fn to_string(suit: Suit) {
  case suit {
    Spades -> "spades"
    Diamonds -> "diamonds"
    Clubs -> "clubs"
    Hearts -> "hearts"
  }
}

pub fn from_string(suit_string: String) {
  case suit_string {
    "spades" -> Ok(Spades)
    "diamonds" -> Ok(Diamonds)
    "clubs" -> Ok(Clubs)
    "hearts" -> Ok(Hearts)
    _ -> Error(Nil)
  }
}

pub fn json(suit: Suit) {
  suit |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(suit_string) {
    case from_string(suit_string) {
      Ok(suit) -> decode.success(suit)
      Error(_) -> decode.failure(Spades, "suit")
    }
  })
}

pub fn strong(suit: Suit) {
  case suit {
    Spades -> Diamonds
    Diamonds -> Clubs
    Clubs -> Hearts
    Hearts -> Spades
  }
}

pub fn weak(suit: Suit) {
  case suit {
    Spades -> Hearts
    Diamonds -> Spades
    Clubs -> Diamonds
    Hearts -> Clubs
  }
}
