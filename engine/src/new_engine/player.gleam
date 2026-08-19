import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import new_engine/card.{type Card}
import new_engine/color.{type Color}
import yuzu

pub type Player {
  Managed(color: Color, hand: List(Card), deck: List(Card))
  Controlled(color: Color, hand: List(Card), deck: Int)
  Observed(color: Color, hand: Int, deck: Int)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player: Player) {
  case player {
    Managed(color, hand, deck) ->
      json.object([
        #("color", color.json(color)),
        #("hand", json.array(hand, card.json)),
        #("deck", json.array(deck, card.json)),
      ])

    Controlled(color, hand, deck) ->
      json.object([
        #("color", color.json(color)),
        #("hand", json.array(hand, card.json)),
        #("deck", json.int(deck)),
      ])

    Observed(color, hand, deck) ->
      json.object([
        #("color", color.json(color)),
        #("hand", json.int(hand)),
        #("deck", json.int(deck)),
      ])
  }
}

pub fn decoder() {
  use color <- decode.field("color", color.decoder())

  let managed_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.list(card.decoder()))
    decode.success(Managed(color:, hand:, deck:))
  }

  let controlled_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.int)
    decode.success(Controlled(color:, hand:, deck:))
  }

  let observed_decoder = {
    use hand <- decode.field("hand", decode.int)
    use deck <- decode.field("deck", decode.int)
    decode.success(Observed(color:, hand:, deck:))
  }

  decode.one_of(managed_decoder, [controlled_decoder, observed_decoder])
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_managed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, List(Card), List(Card)) -> return_value,
) {
  case player {
    Managed(color, hand, deck) -> callback(color, hand, deck)
    _ -> default_return_value
  }
}

pub fn use_controlled(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, List(Card), Int) -> return_value,
) {
  case player {
    Controlled(color, hand, deck) -> callback(color, hand, deck)
    _ -> default_return_value
  }
}

pub fn use_observed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, Int, Int) -> return_value,
) {
  case player {
    Observed(color, hand, deck) -> callback(color, hand, deck)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn has_empty_hand(player: Player) {
  case player {
    Managed(_, hand, _) -> list.is_empty(hand)
    Controlled(_, hand, _) -> list.is_empty(hand)
    Observed(_, hand, _) -> hand == 0
  }
}

pub fn deploy(player: Player, card: Card) {
  case player {
    Managed(_, hand, _) -> {
      use <- yuzu.true(list.contains(hand, card), Error(Nil))
      let hand = list.filter(player.hand, fn(c) { c != card })
      Ok(Managed(..player, hand:))
    }

    Controlled(_, hand, _) -> {
      use <- yuzu.true(list.contains(hand, card), Error(Nil))
      let hand = list.filter(player.hand, fn(c) { c != card })
      Ok(Controlled(..player, hand:))
    }

    Observed(_, _, _) -> Error(Nil)
  }
}

pub fn draw_until(player: Player, max: Int) {
  use color, hand, deck <- use_managed(player, Error(Nil))

  let #(hand, deck) =
    int.range(0, max - list.length(hand), #(hand, deck), fn(hand_deck, _) {
      case hand_deck.1 {
        [] -> hand_deck
        [card, ..deck] -> #(list.prepend(hand_deck.0, card), deck)
      }
    })

  Ok(Managed(color:, hand:, deck:))
}
