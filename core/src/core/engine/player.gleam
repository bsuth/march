import core/engine/card.{type Card}
import core/util
import gleam/dynamic/decode
import gleam/json
import gleam/list

pub type Player {
  Managed(index: Int, deck: List(Card), hand: List(Card), discard: List(Card))
  Controlled(index: Int, deck: Int, hand: List(Card), discard: List(Card))
  Observed(index: Int, deck: Int, hand: Int, discard: List(Card))
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player: Player) {
  case player {
    Managed(index, deck, hand, discard) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.array(deck, card.json)),
        #("hand", json.array(hand, card.json)),
        #("discard", json.array(discard, card.json)),
      ])

    Controlled(index, deck, hand, discard) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.array(hand, card.json)),
        #("discard", json.array(discard, card.json)),
      ])

    Observed(index, deck, hand, discard) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.int(hand)),
        #("discard", json.array(discard, card.json)),
      ])
  }
}

pub fn decoder() {
  use index <- decode.field("index", decode.int)
  use discard <- decode.field("discard", decode.list(card.decoder()))

  let managed_decoder = {
    use deck <- decode.field("deck", decode.list(card.decoder()))
    use hand <- decode.field("hand", decode.list(card.decoder()))
    decode.success(Managed(index:, deck:, hand:, discard:))
  }

  let controlled_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.int)
    decode.success(Controlled(index:, deck:, hand:, discard:))
  }

  let observed_decoder = {
    use hand <- decode.field("hand", decode.int)
    use deck <- decode.field("deck", decode.int)
    decode.success(Observed(index:, deck:, hand:, discard:))
  }

  decode.one_of(managed_decoder, [controlled_decoder, observed_decoder])
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_managed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, List(Card), List(Card), List(Card)) -> return_value,
) {
  case player {
    Managed(index, deck, hand, discard) -> callback(index, deck, hand, discard)
    _ -> default_return_value
  }
}

pub fn use_controlled(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, Int, List(Card), List(Card)) -> return_value,
) {
  case player {
    Controlled(index, deck, hand, discard) ->
      callback(index, deck, hand, discard)
    _ -> default_return_value
  }
}

pub fn use_observed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, Int, Int, List(Card)) -> return_value,
) {
  case player {
    Observed(index, deck, hand, discard) -> callback(index, hand, deck, discard)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn is_managed(player: Player) {
  case player {
    Managed(..) -> True
    Controlled(..) -> False
    Observed(..) -> False
  }
}

pub fn is_controlled(player: Player) {
  case player {
    Managed(..) -> False
    Controlled(..) -> True
    Observed(..) -> False
  }
}

pub fn is_observed(player: Player) {
  case player {
    Managed(..) -> False
    Controlled(..) -> False
    Observed(..) -> True
  }
}

pub fn to_managed(player: Player) {
  case player {
    Managed(..) -> Ok(player)
    Controlled(..) -> Error(Nil)
    Observed(..) -> Error(Nil)
  }
}

pub fn to_controlled(player: Player) {
  case player {
    Managed(index, deck, hand, discard) ->
      Ok(Controlled(index, list.length(deck), hand, discard))
    Controlled(..) -> Ok(player)
    Observed(..) -> Error(Nil)
  }
}

pub fn to_observed(player: Player) {
  case player {
    Managed(index, deck, hand, discard) ->
      Observed(index, list.length(deck), list.length(hand), discard)
    Controlled(index, deck, hand, discard) ->
      Observed(index, deck, list.length(hand), discard)
    Observed(..) -> player
  }
}

pub fn has_empty_hand(player: Player) {
  case player {
    Managed(_, _, hand, _) -> list.is_empty(hand)
    Controlled(_, _, hand, _) -> list.is_empty(hand)
    Observed(_, _, hand, _) -> hand == 0
  }
}

pub fn is_holding(player: Player, card: Card) {
  case player {
    Managed(_, _, hand, _) -> list.contains(hand, card)
    Controlled(_, _, hand, _) -> list.contains(hand, card)
    Observed(..) -> False
  }
}

pub fn deploy(player: Player, deploy_card: Card) {
  case player {
    Managed(_, _, hand, _) ->
      Managed(..player, hand: list.filter(hand, util.neq(_, deploy_card)))
    Controlled(_, _, hand, _) ->
      Controlled(..player, hand: list.filter(hand, util.neq(_, deploy_card)))
    Observed(_, _, hand, _) -> Observed(..player, hand: hand - 1)
  }
}

pub fn draw(player: Player, card: Card) {
  case player {
    Managed(_, deck, hand, _) ->
      Managed(
        ..player,
        deck: list.drop(deck, 1),
        hand: list.prepend(hand, card),
      )

    Controlled(_, deck, hand, _) ->
      Controlled(..player, deck: deck - 1, hand: list.prepend(hand, card))

    Observed(_, deck, hand, _) ->
      Observed(..player, deck: deck - 1, hand: hand + 1)
  }
}
