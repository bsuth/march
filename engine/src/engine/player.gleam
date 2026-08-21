import engine/card.{type Card}
import engine/color.{type Color}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import yuzu

pub type Player {
  Managed(color: Color, deck: List(Card), hand: List(Card), max_hand_size: Int)
  Controlled(color: Color, deck: Int, hand: List(Card), max_hand_size: Int)
  Observed(color: Color, deck: Int, hand: Int, max_hand_size: Int)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player: Player) {
  case player {
    Managed(color, deck, hand, max_hand_size) ->
      json.object([
        #("color", color.json(color)),
        #("deck", json.array(deck, card.json)),
        #("hand", json.array(hand, card.json)),
        #("max_hand_size", json.int(max_hand_size)),
      ])

    Controlled(color, deck, hand, max_hand_size) ->
      json.object([
        #("color", color.json(color)),
        #("deck", json.int(deck)),
        #("hand", json.array(hand, card.json)),
        #("max_hand_size", json.int(max_hand_size)),
      ])

    Observed(color, deck, hand, max_hand_size) ->
      json.object([
        #("color", color.json(color)),
        #("deck", json.int(deck)),
        #("hand", json.int(hand)),
        #("max_hand_size", json.int(max_hand_size)),
      ])
  }
}

pub fn decoder() {
  use color <- decode.field("color", color.decoder())
  use max_hand_size <- decode.field("max_hand_size", decode.int)

  let managed_decoder = {
    use deck <- decode.field("deck", decode.list(card.decoder()))
    use hand <- decode.field("hand", decode.list(card.decoder()))
    decode.success(Managed(color:, deck:, hand:, max_hand_size:))
  }

  let controlled_decoder = {
    use hand <- decode.field("hand", decode.list(card.decoder()))
    use deck <- decode.field("deck", decode.int)
    decode.success(Controlled(color:, deck:, hand:, max_hand_size:))
  }

  let observed_decoder = {
    use hand <- decode.field("hand", decode.int)
    use deck <- decode.field("deck", decode.int)
    decode.success(Observed(color:, deck:, hand:, max_hand_size:))
  }

  decode.one_of(managed_decoder, [controlled_decoder, observed_decoder])
}

// -----------------------------------------------------------------------------
// Use
// -----------------------------------------------------------------------------

pub fn use_managed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, List(Card), List(Card), Int) -> return_value,
) {
  case player {
    Managed(color, deck, hand, max_hand_size) ->
      callback(color, deck, hand, max_hand_size)
    _ -> default_return_value
  }
}

pub fn use_controlled(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, Int, List(Card), Int) -> return_value,
) {
  case player {
    Controlled(color, deck, hand, max_hand_size) ->
      callback(color, deck, hand, max_hand_size)
    _ -> default_return_value
  }
}

pub fn use_observed(
  player: Player,
  default_return_value: return_value,
  callback: fn(Color, Int, Int, Int) -> return_value,
) {
  case player {
    Observed(color, deck, hand, max_hand_size) ->
      callback(color, hand, deck, max_hand_size)
    _ -> default_return_value
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn has_empty_hand(player: Player) {
  case player {
    Managed(_, _, hand, _) -> list.is_empty(hand)
    Controlled(_, _, hand, _) -> list.is_empty(hand)
    Observed(_, _, hand, _) -> hand == 0
  }
}

pub fn deploy(player: Player, card: Card) {
  case player {
    Managed(_, _, hand, _) -> {
      use hand <- yuzu.ok(deploy_first(hand, card), Error(Nil))
      Ok(Managed(..player, hand:))
    }

    Controlled(_, _, hand, _) -> {
      use hand <- yuzu.ok(deploy_first(hand, card), Error(Nil))
      Ok(Controlled(..player, hand:))
    }

    Observed(..) -> Error(Nil)
  }
}

fn deploy_first(hand: List(Card), card: Card) {
  use head, tail <- yuzu.non_empty_list(hand, Error(Nil))
  use <- yuzu.false(head == card, Ok(tail))
  result.map(deploy_first(tail, card), list.prepend(_, head))
}

pub fn draw(player: Player) {
  use color, deck, hand, max_hand_size <- use_managed(player, Error(Nil))

  let #(hand, deck) =
    int.range(
      0,
      max_hand_size - list.length(hand),
      #(hand, deck),
      fn(hand_deck, _) {
        case hand_deck.1 {
          [] -> hand_deck
          [card, ..deck] -> #(list.prepend(hand_deck.0, card), deck)
        }
      },
    )

  Ok(Managed(color:, deck:, hand:, max_hand_size:))
}
