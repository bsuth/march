pub type CardSuit {
  Spades
  Diamonds
  Clubs
  Hearts
}

pub type CardValue {
  Jack
  Queen
  King
  Ace
}

pub type Card {
  Card(value: CardValue, suit: CardSuit)
}

pub const standard_deck = [
  Card(value: Jack, suit: Spades),
  Card(value: Queen, suit: Spades),
  Card(value: King, suit: Spades),
  Card(value: Ace, suit: Spades),
  Card(value: Jack, suit: Diamonds),
  Card(value: Queen, suit: Diamonds),
  Card(value: King, suit: Diamonds),
  Card(value: Ace, suit: Diamonds),
  Card(value: Jack, suit: Clubs),
  Card(value: Queen, suit: Clubs),
  Card(value: King, suit: Clubs),
  Card(value: Ace, suit: Clubs),
  Card(value: Jack, suit: Hearts),
  Card(value: Queen, suit: Hearts),
  Card(value: King, suit: Hearts),
  Card(value: Ace, suit: Hearts),
]

pub fn can_capture(a: Card, b: Card) {
  case a.suit, b.suit {
    Spades, Spades -> can_capture_value(a.value, b.value)
    Spades, Diamonds -> True
    Spades, Clubs -> can_capture_value(a.value, b.value)
    Spades, Hearts -> False
    Diamonds, Spades -> False
    Diamonds, Diamonds -> can_capture_value(a.value, b.value)
    Diamonds, Clubs -> True
    Diamonds, Hearts -> can_capture_value(a.value, b.value)
    Clubs, Spades -> can_capture_value(a.value, b.value)
    Clubs, Diamonds -> False
    Clubs, Clubs -> can_capture_value(a.value, b.value)
    Clubs, Hearts -> True
    Hearts, Spades -> True
    Hearts, Diamonds -> can_capture_value(a.value, b.value)
    Hearts, Clubs -> False
    Hearts, Hearts -> can_capture_value(a.value, b.value)
  }
}

fn can_capture_value(a: CardValue, b: CardValue) {
  case a, b {
    Jack, Jack -> True
    Jack, _ -> False
    Queen, Jack -> True
    Queen, Queen -> True
    Queen, _ -> False
    King, Ace -> False
    King, _ -> True
    Ace, _ -> True
  }
}
