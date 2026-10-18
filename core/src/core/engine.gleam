import core/engine/card
import core/engine/move
import core/engine/player.{type Player}
import core/engine/position.{type Position}
import core/engine/settings.{type Settings}
import core/engine/turn.{type Turn}
import core/util
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import yuzu

pub type Engine {
  Engine(
    active_player_index: Int,
    players: List(Player),
    position: Position,
    seeds: List(Player),
    settings: Settings,
    turns: List(Turn),
  )
}

pub fn new(settings: Settings) {
  let num_players = case settings.doubles {
    True -> 4
    False -> 2
  }

  let seeds =
    int.range(num_players - 1, -1, [], fn(players, index) {
      card.deck(index)
      |> list.shuffle()
      |> list.split(settings.hand_size)
      |> fn(split) { player.Managed(index, split.1, split.0, []) }
      |> list.prepend(players, _)
    })

  let position =
    int.range(
      0,
      settings.board.width * settings.board.height,
      dict.new(),
      fn(position, index) { dict.insert(position, index, option.None) },
    )

  Engine(
    active_player_index: 0,
    players: seeds,
    position:,
    seeds:,
    settings:,
    turns: [],
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(engine: Engine) {
  json.object([
    #("active_player_index", json.int(engine.active_player_index)),
    #("players", json.array(engine.players, player.json)),
    #("position", position.json(engine.position)),
    #("seeds", json.array(engine.seeds, player.json)),
    #("settings", settings.json(engine.settings)),
    #("turns", json.array(engine.turns, turn.json)),
  ])
}

pub fn decoder() {
  use active_player_index <- decode.field("active_player_index", decode.int)
  use players <- decode.field("players", decode.list(player.decoder()))
  use position <- decode.field("position", position.decoder())
  use seeds <- decode.field("seeds", decode.list(player.decoder()))
  use settings <- decode.field("settings", settings.decoder())
  use turns <- decode.field("turns", decode.list(turn.decoder()))

  decode.success(Engine(
    active_player_index:,
    players:,
    position:,
    seeds:,
    settings:,
    turns:,
  ))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn validate_turn_request(engine: Engine, turn_request: turn.Request) {
  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  use <- yuzu.true_(case turn_request.lead {
    option.Some(lead) ->
      move.list_valid_dest_indices(
        lead.0,
        engine.active_player_index,
        engine.position,
        engine.settings,
      )
      |> list.contains(lead.1)

    option.None ->
      list.all(dict.keys(engine.position), fn(index) {
        move.list_valid_dest_indices(
          index,
          engine.active_player_index,
          engine.position,
          engine.settings,
        )
        |> list.is_empty()
      })
  })

  use _ <- yuzu.ok(
    case turn_request.lead {
      option.None -> Ok(dict.new())
      option.Some(lead) ->
        turn_request.marches
        |> list.prepend(lead.0)
        |> list.prepend(lead.1)
        |> list.try_fold(dict.new(), fn(indices, index) {
          case dict.has_key(indices, index) {
            True -> Error(Nil)
            False -> Ok(dict.insert(indices, index, True))
          }
        })
    },
    False,
  )

  use <- yuzu.true_(case turn_request.lead {
    option.Some(lead) ->
      turn_request.marches
      |> list.prepend(lead.0)
      |> list.window_by_2()
      |> list.all(fn(move) {
        position.is_occupied(engine.position, move.1, active_player.index)
        && move.is_march_index(
          move.1,
          move.0,
          engine.active_player_index,
          engine.position,
          engine.settings,
        )
        && move.list_raw_dest_indices(move.1, engine.position, engine.settings)
        |> list.contains(move.0)
      })

    option.None -> list.is_empty(turn_request.marches)
  })

  let player_base_index =
    settings.get_base_index(engine.settings, active_player.index)

  let is_base_empty = case turn_request.lead {
    option.Some(lead) ->
      turn_request.marches
      |> list.reverse()
      |> list.first()
      |> result.unwrap(lead.0)
      |> fn(final_source_index) { final_source_index == player_base_index }

    option.None -> position.is_none(engine.position, player_base_index)
  }

  case turn_request.deploy {
    option.Some(card) -> is_base_empty && player.is_holding(active_player, card)
    option.None -> !is_base_empty
  }
}

pub fn preview_turn_request(engine: Engine, turn_request: turn.Request) {
  let assert Ok(capture) = {
    case turn_request.lead {
      option.Some(#(capture_board_index, _)) ->
        dict.get(engine.position, capture_board_index)
      _ -> Ok(option.None)
    }
  }

  apply_turn(
    engine,
    turn.Observed(
      capture,
      turn_request.lead,
      turn_request.marches,
      turn_request.deploy,
      False,
    ),
  )
}

pub fn resolve_turn_request(engine: Engine, turn_request: turn.Request) {
  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  let assert Ok(capture) = {
    case turn_request.lead {
      option.Some(#(capture_board_index, _)) ->
        dict.get(engine.position, capture_board_index)
      _ -> Ok(option.None)
    }
  }

  case active_player {
    player.Managed(_, deck, _, _) -> {
      turn.Controlled(
        capture,
        turn_request.lead,
        turn_request.marches,
        turn_request.deploy,
        case deck {
          [head, ..] -> option.Some(head)
          _ -> option.None
        },
      )
    }

    player.Controlled(_, deck, _, _) | player.Observed(_, deck, _, _) ->
      turn.Observed(
        capture,
        turn_request.lead,
        turn_request.marches,
        turn_request.deploy,
        deck > 0,
      )
  }
}

pub fn apply_turn_request(engine: Engine, turn_request: turn.Request) {
  engine
  |> resolve_turn_request(turn_request)
  |> apply_turn(engine, _)
}

pub fn commit_turn_request(engine: Engine, turn_request: turn.Request) {
  use <- yuzu.true(validate_turn_request(engine, turn_request), Error(Nil))

  engine
  |> resolve_turn_request(turn_request)
  |> commit_turn(engine, _)
  |> Ok()
}

pub fn apply_turn(engine: Engine, turn: Turn) {
  let assert Ok(active_player) =
    util.get_list_index(engine.players, engine.active_player_index)

  let assert Ok(players) = {
    use capture_card <- yuzu.some(turn.capture, Ok(engine.players))

    let assert Ok(capture_player) =
      util.get_list_index(engine.players, capture_card.player_index)

    let capture_player_discard =
      list.prepend(capture_player.discard, capture_card)

    let capture_player = case capture_player {
      player.Managed(index, deck, hand, _) ->
        player.Managed(index, deck, hand, capture_player_discard)
      player.Controlled(index, deck, hand, _) ->
        player.Controlled(index, deck, hand, capture_player_discard)
      player.Observed(index, deck, hand, _) ->
        player.Observed(index, deck, hand, capture_player_discard)
    }

    util.set_list_index(
      engine.players,
      capture_card.player_index,
      capture_player,
    )
  }

  let position = case turn.lead {
    option.Some(lead) ->
      turn.marches
      |> list.prepend(lead.0)
      |> list.prepend(lead.1)
      |> list.reverse()
      |> list.window_by_2()
      |> list.reverse()
      |> position.move_many(engine.position, _)

    option.None -> engine.position
  }

  let #(active_player, position) = {
    use deploy_card <- yuzu.some(turn.deploy, #(active_player, position))

    #(
      player.deploy(active_player, deploy_card),
      position.insert_one(position, #(
        settings.get_base_index(engine.settings, active_player.index),
        option.Some(deploy_card),
      )),
    )
  }

  let active_player = case turn {
    turn.Controlled(_, _, _, _, option.Some(draw_card)) ->
      player.draw(active_player, draw_card)

    turn.Observed(_, _, _, _, True) -> {
      let assert player.Observed(color, deck, hand, discard) = active_player
      player.Observed(color, deck - 1, hand + 1, discard)
    }

    _ -> active_player
  }

  let assert Ok(players) =
    util.set_list_index(players, engine.active_player_index, active_player)

  Engine(..engine, players:, position:)
}

pub fn commit_turn(engine: Engine, turn: Turn) {
  Engine(..engine, turns: list.prepend(engine.turns, turn))
  |> apply_turn(turn)
  |> end_turn()
}

pub fn end_turn(engine: Engine) {
  Engine(..engine, active_player_index: case engine.settings.doubles {
    True -> { engine.active_player_index + 1 } % 4
    False -> { engine.active_player_index + 1 } % 2
  })
}

pub fn undo_turn(engine: Engine) {
  // TODO
  // TODO: handle captures!
  engine
}

pub fn undo_turn_action(engine: Engine) {
  // TODO
  // TODO: handle captures!
  engine
}
