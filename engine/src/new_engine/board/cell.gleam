import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}
import new_engine/board/tile.{type Tile}
import new_engine/card.{type Card}

pub type Cell {
  Cell(index: Int, tile: Tile, card: Option(Card))
}

pub fn json(cell: Cell) {
  json.object([
    #("index", json.int(cell.index)),
    #("tile", tile.json(cell.tile)),
    #("card", json.nullable(cell.card, card.json)),
  ])
}

pub fn decoder() {
  use index <- decode.field("index", decode.int)
  use tile <- decode.field("tile", tile.decoder())
  use card <- decode.field("card", decode.optional(card.decoder()))
  decode.success(Cell(index:, tile:, card:))
}
