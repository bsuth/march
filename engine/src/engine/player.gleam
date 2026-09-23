import engine/card.{type Card}
import engine/settings.{type Settings}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list

pub type Player {
  Managed(index: Int, deck: List(Card), hand: List(Card))
  Controlled(index: Int, deck: Int, hand: List(Card))
  Observed(index: Int, deck: Int, hand: Int)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player: Player) {
  case player {
    Managed(index, deck, hand) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.array(deck, card.json)),
        #("hand", json.array(hand, card.json)),
      ])

    Controlled(index, deck, hand) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.array(hand, card.json)),
      ])

    Observed(index, deck, hand) ->
      json.object([
        #("index", json.int(index)),
        #("deck", json.int(deck)),
        #("hand", json.int(hand)),
      ])
  }
}

pub fn decoder() {
  use index <- decode.field("index", decode.int)

  let managed_decoder = {
    use deck <- decode.field("deck", decode.list(card.decoder()))
    use hand <- decode.field("hand", decode.list(card.decoder()))
    decode.success(Managed(index:, deck:, hand:))
  }

  let controlled_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.int)
    decode.success(Controlled(index:, deck:, hand:))
  }

  let observed_decoder = {
    use hand <- decode.field("hand", decode.int)
    use deck <- decode.field("deck", decode.int)
    decode.success(Observed(index:, deck:, hand:))
  }

  decode.one_of(managed_decoder, [controlled_decoder, observed_decoder])
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_managed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, List(Card), List(Card)) -> return_value,
) {
  case player {
    Managed(index, deck, hand) -> callback(index, deck, hand)
    _ -> default_return_value
  }
}

pub fn use_controlled(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, Int, List(Card)) -> return_value,
) {
  case player {
    Controlled(index, deck, hand) -> callback(index, deck, hand)
    _ -> default_return_value
  }
}

pub fn use_observed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Int, Int, Int) -> return_value,
) {
  case player {
    Observed(index, deck, hand) -> callback(index, hand, deck)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn to_managed(player: Player) {
  case player {
    Managed(..) -> Ok(player)
    Controlled(..) -> Error(Nil)
    Observed(..) -> Error(Nil)
  }
}

pub fn to_controlled(player: Player) {
  case player {
    Managed(index, deck, hand) -> Ok(Controlled(index, list.length(deck), hand))
    Controlled(..) -> Ok(player)
    Observed(..) -> Error(Nil)
  }
}

pub fn to_observed(player: Player) {
  case player {
    Managed(index, deck, hand) ->
      Observed(index, list.length(deck), list.length(hand))
    Controlled(index, deck, hand) -> Observed(index, deck, list.length(hand))
    Observed(..) -> player
  }
}

pub fn has_empty_hand(player: Player) {
  case player {
    Managed(_, _, hand) -> list.is_empty(hand)
    Controlled(_, _, hand) -> list.is_empty(hand)
    Observed(_, _, hand) -> hand == 0
  }
}

pub fn is_holding(player: Player, card: Card) {
  case player {
    Managed(_, _, hand) -> list.contains(hand, card)
    Controlled(_, _, hand) -> list.contains(hand, card)
    Observed(..) -> False
  }
}

pub fn deploy(player: Player, deploy_card: Card) {
  case player {
    Managed(_, _, hand) -> {
      let hand = list.filter(hand, fn(hand_card) { hand_card != deploy_card })
      Ok(Managed(..player, hand:))
    }

    Controlled(_, _, hand) -> {
      let hand = list.filter(hand, fn(hand_card) { hand_card != deploy_card })
      Ok(Controlled(..player, hand:))
    }

    Observed(..) -> Error(Nil)
  }
}

pub fn draw(player: Player, settings: Settings) {
  use index, deck, hand <- use_managed(player, Error(Nil))

  let #(deck, hand) =
    int.range(
      0,
      settings.hand_size - list.length(hand),
      #(deck, hand),
      fn(acc, _) {
        case acc.0 {
          [] -> acc
          [card, ..deck] -> #(list.prepend(acc.1, card), deck)
        }
      },
    )

  Ok(Managed(index:, deck:, hand:))
}
