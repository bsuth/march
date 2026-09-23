import gleam/dynamic/decode
import gleam/json

pub type Tile {
  Normal
  // Cards may not occupy this cell
  // Empty
  // Cards on this cell are treated w/ a different suit
  // SuitTransform(card.Suit)
  // Cards on this cell are treated w/ a different value
  // ValueTransform(card.Value)
  // Cards on this cell may be swapped with the destination index as a move
  // Swap(Int)
  // When occupying this cell, you may deploy cards here after moving
  // Deploy
  // Cards may only occupy this cell for the given number of turns. When
  // exceeded, the card is destroyed.
  // Countdown(Int)
}

pub fn to_string(tile: Tile) {
  case tile {
    Normal -> "normal"
  }
}

pub fn from_string(tile_string: String) {
  case tile_string {
    "normal" -> Ok(Normal)
    _ -> Error(Nil)
  }
}

pub fn json(tile: Tile) {
  tile |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(tile_string) {
    case from_string(tile_string) {
      Ok(tile) -> decode.success(tile)
      Error(_) -> decode.failure(Normal, "tile")
    }
  })
}
