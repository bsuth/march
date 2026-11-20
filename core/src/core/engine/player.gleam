import core/engine/card.{type Card}
import core/engine/card_art.{type CardArt}
import core/util
import gleam/dynamic/decode
import gleam/json
import gleam/list

pub type Player {
  Managed(
    index: Int,
    deck: List(Card),
    hand: List(Card),
    discard: List(Card),
    card_art: CardArt,
  )
  Controlled(
    index: Int,
    deck: Int,
    hand: List(Card),
    discard: List(Card),
    card_art: CardArt,
  )
  Observed(
    index: Int,
    deck: Int,
    hand: Int,
    discard: List(Card),
    card_art: CardArt,
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player: Player) {
  case player {
    Managed(index, deck, hand, discard, card_art) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.array(deck, card.json)),
        #("hand", json.array(hand, card.json)),
        #("discard", json.array(discard, card.json)),
        #("card_art", card_art.json(card_art)),
      ])

    Controlled(index, deck, hand, discard, card_art) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.array(hand, card.json)),
        #("discard", json.array(discard, card.json)),
        #("card_art", card_art.json(card_art)),
      ])

    Observed(index, deck, hand, discard, card_art) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.int(hand)),
        #("discard", json.array(discard, card.json)),
        #("card_art", card_art.json(card_art)),
      ])
  }
}

pub fn decoder() {
  use index <- decode.field("index", decode.int)
  use discard <- decode.field("discard", decode.list(card.decoder()))
  use card_art <- decode.field("card_art", card_art.decoder())

  let managed_decoder = {
    use deck <- decode.field("deck", decode.list(card.decoder()))
    use hand <- decode.field("hand", decode.list(card.decoder()))
    decode.success(Managed(index:, deck:, hand:, discard:, card_art:))
  }

  let controlled_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.int)
    decode.success(Controlled(index:, deck:, hand:, discard:, card_art:))
  }

  let observed_decoder = {
    use hand <- decode.field("hand", decode.int)
    use deck <- decode.field("deck", decode.int)
    decode.success(Observed(index:, deck:, hand:, discard:, card_art:))
  }

  decode.one_of(managed_decoder, [controlled_decoder, observed_decoder])
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_managed(
  player: Player,
  default_return_value: return_value,
  callback: fn(List(Card), List(Card)) -> return_value,
) {
  case player {
    Managed(_, deck, hand, ..) -> callback(deck, hand)
    _ -> default_return_value
  }
}

pub fn use_controlled(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, List(Card)) -> return_value,
) {
  case player {
    Controlled(_, deck, hand, ..) -> callback(deck, hand)
    _ -> default_return_value
  }
}

pub fn use_observed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, Int) -> return_value,
) {
  case player {
    Observed(_, deck, hand, ..) -> callback(hand, deck)
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
    Managed(index, deck, hand, discard, card_art) ->
      Ok(Controlled(index, list.length(deck), hand, discard, card_art))
    Controlled(..) -> Ok(player)
    Observed(..) -> Error(Nil)
  }
}

pub fn to_observed(player: Player) {
  case player {
    Managed(index, deck, hand, discard, card_art) ->
      Observed(index, list.length(deck), list.length(hand), discard, card_art)
    Controlled(index, deck, hand, discard, card_art) ->
      Observed(index, deck, list.length(hand), discard, card_art)
    Observed(..) -> player
  }
}

pub fn has_empty_hand(player: Player) {
  case player {
    Managed(_, _, hand, ..) -> list.is_empty(hand)
    Controlled(_, _, hand, ..) -> list.is_empty(hand)
    Observed(_, _, hand, ..) -> hand == 0
  }
}

pub fn is_holding(player: Player, card: Card) {
  case player {
    Managed(_, _, hand, ..) -> list.contains(hand, card)
    Controlled(_, _, hand, ..) -> list.contains(hand, card)
    Observed(..) -> False
  }
}

pub fn deploy(player: Player, deploy_card: Card) {
  case player {
    Managed(_, _, hand, ..) ->
      Managed(..player, hand: list.filter(hand, util.neq(_, deploy_card)))
    Controlled(_, _, hand, ..) ->
      Controlled(..player, hand: list.filter(hand, util.neq(_, deploy_card)))
    Observed(_, _, hand, ..) -> Observed(..player, hand: hand - 1)
  }
}

pub fn draw(player: Player, card: Card) {
  case player {
    Managed(_, deck, hand, ..) ->
      Managed(
        ..player,
        deck: list.drop(deck, 1),
        hand: list.prepend(hand, card),
      )

    Controlled(_, deck, hand, ..) ->
      Controlled(..player, deck: deck - 1, hand: list.prepend(hand, card))

    Observed(_, deck, hand, ..) ->
      Observed(..player, deck: deck - 1, hand: hand + 1)
  }
}
