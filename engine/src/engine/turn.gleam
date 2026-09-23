import engine/board.{type Board}
import engine/card.{type Card}
import engine/move
import engine/player.{type Player}
import engine/settings.{type Settings}
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import yuzu

pub type Turn {
  Controlled(
    lead: Option(#(Int, Int)),
    marches: List(Int),
    deploy: Option(Card),
    draw: Option(Card),
  )
  Observed(
    lead: Option(#(Int, Int)),
    marches: List(Int),
    deploy: Option(Card),
    draw: Bool,
  )
}

pub type Request {
  Request(lead: Option(#(Int, Int)), marches: List(Int), deploy: Option(Card))
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(turn: Turn) {
  json.object([
    #(
      "lead",
      json.nullable(turn.lead, fn(lead) {
        json.object([
          #("source", json.int(lead.0)),
          #("dest", json.int(lead.1)),
        ])
      }),
    ),
    #("marches", json.array(turn.marches, json.int)),
    #("deploy", json.nullable(turn.deploy, card.json)),
    #("draw", case turn {
      Controlled(_, _, _, draw) -> json.nullable(draw, card.json)
      Observed(_, _, _, draw) -> json.bool(draw)
    }),
  ])
}

pub fn decoder() {
  use lead <- decode.field(
    "lead",
    decode.optional({
      use source <- decode.field("source", decode.int)
      use dest <- decode.field("dest", decode.int)
      decode.success(#(source, dest))
    }),
  )

  use marches <- decode.field("marches", decode.list(decode.int))
  use deploy <- decode.field("deploy", decode.optional(card.decoder()))

  let controlled_decoder = {
    use draw <- decode.field("draw", decode.optional(card.decoder()))
    decode.success(Controlled(lead:, marches:, deploy:, draw:))
  }

  let observed_decoder = {
    use draw <- decode.field("draw", decode.bool)
    decode.success(Observed(lead:, marches:, deploy:, draw:))
  }

  decode.one_of(controlled_decoder, [observed_decoder])
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn validate(
  request: Request,
  player: Player,
  board: Board,
  settings: Settings,
) {
  use <- yuzu.true_(case request.lead {
    option.Some(lead) ->
      move.list_valid_dest_indices(lead.0, player, board, settings)
      |> list.contains(lead.1)

    option.None ->
      list.all(dict.keys(board), fn(index) {
        move.list_valid_dest_indices(index, player, board, settings)
        |> list.is_empty()
      })
  })

  use <- yuzu.true_(case request.lead {
    option.Some(lead) ->
      request.marches
      |> list.prepend(lead.0)
      |> list.window_by_2()
      |> list.all(fn(move) {
        board.is_occupied(board, move.1, player.index)
        && move.is_march_index(move.1, move.0, player, board, settings)
        && move.list_raw_dest_indices(move.1, board, settings)
        |> list.contains(move.0)
      })

    option.None -> list.is_empty(request.marches)
  })

  let player_base_index = board.get_base_index(settings, player.index)

  let is_base_empty = case request.lead {
    option.Some(lead) ->
      request.marches
      |> list.reverse()
      |> list.first()
      |> result.unwrap(lead.0)
      |> fn(final_source_index) { final_source_index == player_base_index }

    option.None -> board.is_none(board, player_base_index)
  }

  case request.deploy {
    option.Some(card) -> is_base_empty && player.is_holding(player, card)
    option.None -> !is_base_empty
  }
}

pub fn do(turn: Turn, player: Player, board: Board, settings: Settings) {
  let board = case turn.lead {
    option.Some(lead) ->
      turn.marches
      |> list.prepend(lead.0)
      |> list.prepend(lead.1)
      |> list.window_by_2()
      |> board.move_many(board, _)

    option.None -> board
  }

  let board = case turn.deploy {
    option.Some(card) ->
      board.insert_one(board, #(
        board.get_base_index(settings, player.index),
        option.Some(card),
      ))

    _ -> board
  }

  let player = case turn {
    Controlled(_, _, _, option.Some(card)) -> {
      case player {
        player.Managed(color, deck, hand) ->
          player.Managed(color, deck, list.prepend(hand, card))

        player.Controlled(color, deck, hand) ->
          player.Controlled(color, deck, list.prepend(hand, card))

        player.Observed(color, deck, hand) ->
          player.Observed(color, deck, hand + 1)
      }
    }

    Observed(_, _, _, True) -> {
      let assert player.Observed(color, deck, hand) = player
      player.Observed(color, deck, hand + 1)
    }

    _ -> player
  }

  #(player, board)
}
