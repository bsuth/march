import engine/face.{type Face}
import engine/tile.{type Tile}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json

pub type Settings {
  Settings(
    doubles: Bool,
    hand_size: Int,
    height: Int,
    tiles: Dict(Int, Tile),
    traits: Dict(Face, List(Trait)),
    width: Int,
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(settings: Settings) {
  json.object([
    #("doubles", json.bool(settings.doubles)),
    #("hand_size", json.int(settings.hand_size)),
    #("height", json.int(settings.height)),
    #("tiles", json.dict(settings.tiles, int.to_string, tile.json)),
    #(
      "traits",
      json.dict(settings.traits, face.to_string, json.array(_, trait.json)),
    ),
    #("width", json.int(settings.width)),
  ])
}

pub fn decoder() {
  use doubles <- decode.field("doubles", decode.bool)
  use hand_size <- decode.field("hand_size", decode.int)
  use height <- decode.field("height", decode.int)

  use tiles <- decode.field(
    "tiles",
    decode.dict(
      decode.then(decode.string, fn(key) {
        case int.parse(key) {
          Ok(index) -> decode.success(index)
          Error(_) -> decode.failure(0, "tile index")
        }
      }),
      tile.decoder(),
    ),
  )

  use traits <- decode.field(
    "traits",
    decode.dict(face.decoder(), decode.list(trait.decoder())),
  )

  use width <- decode.field("width", decode.int)

  decode.success(Settings(
    doubles:,
    hand_size:,
    height:,
    tiles:,
    traits:,
    width:,
  ))
}

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------

pub fn classic() {
  let traits =
    dict.new()
    |> dict.insert(face.Jack, [trait.Adjacent])
    |> dict.insert(face.Queen, [trait.Adjacent])
    |> dict.insert(face.King, [trait.Adjacent])
    |> dict.insert(face.Ace, [trait.Adjacent])

  let tiles =
    int.range(0, 16, dict.new(), fn(tiles, index) {
      dict.insert(tiles, index, tile.Normal)
    })

  Settings(doubles: False, hand_size: 4, height: 4, tiles:, traits:, width: 4)
}

pub fn standard() {
  let traits =
    dict.new()
    |> dict.insert(face.Jack, [trait.Adjacent, trait.Diagonal])
    |> dict.insert(face.Queen, [trait.Adjacent, trait.Jump])
    |> dict.insert(face.King, [trait.Adjacent, trait.AnyMarch])
    |> dict.insert(face.Ace, [trait.Adjacent])

  let tiles =
    int.range(0, 16, dict.new(), fn(tiles, index) {
      dict.insert(tiles, index, tile.Normal)
    })

  Settings(doubles: False, hand_size: 4, height: 4, tiles:, traits:, width: 4)
}

pub fn doubles() {
  let traits =
    dict.new()
    |> dict.insert(face.Jack, [trait.Adjacent, trait.AnyMarch])
    |> dict.insert(face.Queen, [trait.Adjacent, trait.AnyMarch])
    |> dict.insert(face.King, [trait.Adjacent, trait.AnyMarch])
    |> dict.insert(face.Ace, [trait.Adjacent, trait.AnyMarch])

  let tiles =
    int.range(0, 25, dict.new(), fn(tiles, index) {
      dict.insert(tiles, index, tile.Normal)
    })

  Settings(doubles: True, hand_size: 4, height: 5, tiles:, traits:, width: 5)
}
