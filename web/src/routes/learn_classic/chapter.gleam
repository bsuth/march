import core/engine
import core/engine/player
import core/engine/settings as engine_settings
import core/engine/turn
import core/util
import gleam/list
import gleam/option

pub type Chapter {
  Introduction
  Deck
  Board
  TurnOverview
  Deploying
  Leading
  Marching
  TurnRecap
  Capturing
  CapturingPractice
  Winning
  Yielding
  Conclusion
}

pub const list = [
  Introduction,
  Deck,
  Board,
  TurnOverview,
  Deploying,
  Leading,
  Marching,
  TurnRecap,
  Capturing,
  CapturingPractice,
  Winning,
  Yielding,
  Conclusion,
]

pub fn to_string(chapter: Chapter) {
  case chapter {
    Introduction -> "introduction"
    Deck -> "deck"
    Board -> "board"
    TurnOverview -> "turn_overview"
    Deploying -> "deploying"
    Leading -> "leading"
    Marching -> "marching"
    TurnRecap -> "turn_recap"
    Capturing -> "capturing"
    CapturingPractice -> "capturing_practice"
    Winning -> "winning"
    Yielding -> "yielding"
    Conclusion -> "conclusion"
  }
}

pub fn from_string(chapter_string: String) {
  case chapter_string {
    "introduction" -> Ok(Introduction)
    "deck" -> Ok(Deck)
    "board" -> Ok(Board)
    "turn_overview" -> Ok(TurnOverview)
    "deploying" -> Ok(Deploying)
    "leading" -> Ok(Leading)
    "marching" -> Ok(Marching)
    "turn_recap" -> Ok(TurnRecap)
    "capturing" -> Ok(Capturing)
    "capturing_practice" -> Ok(CapturingPractice)
    "winning" -> Ok(Winning)
    "yielding" -> Ok(Yielding)
    "conclusion" -> Ok(Conclusion)
    _ -> Error(Nil)
  }
}

pub fn title(chapter: Chapter) {
  case chapter {
    Introduction -> "Introduction"
    Deck -> "The Deck"
    Board -> "The Board"
    TurnOverview -> "Turns"
    Deploying -> "Deploying"
    Leading -> "Leading"
    Marching -> "Marching"
    TurnRecap -> "Turn Recap"
    Capturing -> "Capturing"
    CapturingPractice -> "Capturing Practice"
    Winning -> "Winning"
    Yielding -> "Yielding"
    Conclusion -> "Conclusion"
  }
}

pub fn url(chapter: Chapter) {
  "/learn/classic/" <> to_string(chapter)
}

pub fn previous(chapter: Chapter) {
  list
  |> list.window_by_2()
  |> list.find_map(fn(window) {
    case window.1 == chapter {
      True -> Ok(window.0)
      False -> Error(Nil)
    }
  })
}

pub fn next(chapter: Chapter) {
  list
  |> list.window_by_2()
  |> list.find_map(fn(window) {
    case window.0 == chapter {
      True -> Ok(window.1)
      False -> Error(Nil)
    }
  })
}

pub fn engine(chapter: Chapter) {
  let engine =
    engine_settings.classic()
    |> engine.new_kernel()
    |> engine.new()

  let engine_turns = case chapter {
    Leading -> [
      #(option.None, []),
      #(option.None, []),
    ]

    Marching -> [
      #(option.None, []),
      #(option.None, []),
      #(option.Some(#(0, 4)), []),
      #(option.Some(#(15, 11)), []),
    ]

    TurnRecap -> [
      #(option.None, []),
      #(option.None, []),
      #(option.Some(#(0, 1)), []),
      #(option.Some(#(15, 11)), []),
      #(option.Some(#(1, 5)), [0]),
      #(option.Some(#(15, 14)), []),
      #(option.Some(#(5, 6)), [0, 1]),
      #(option.Some(#(14, 13)), [15]),
    ]

    CapturingPractice -> [
      #(option.None, []),
      #(option.None, []),
      #(option.Some(#(0, 1)), []),
      #(option.Some(#(15, 14)), []),
      #(option.Some(#(1, 2)), [0]),
      #(option.Some(#(14, 13)), [15]),
      #(option.Some(#(2, 3)), [0, 1]),
      #(option.Some(#(13, 12)), [15, 14]),
      #(option.Some(#(3, 7)), [0, 1, 2]),
      #(option.Some(#(12, 8)), [15, 14, 13]),
      #(option.Some(#(2, 6)), [0, 1]),
      #(option.Some(#(13, 9)), [15, 14]),
      #(option.Some(#(1, 5)), [0]),
      #(option.Some(#(14, 10)), [15]),
      #(option.Some(#(0, 4)), []),
      #(option.Some(#(15, 11)), []),
    ]

    _ -> []
  }

  list.fold(engine_turns, engine, fn(engine, engine_turn) {
    echo engine_turn
    let assert Ok(player.Managed(_, _, hand: [deploy_card, ..], ..)) =
      util.get_list_index(engine.players, engine.active_player_index)

    let assert Ok(engine) =
      engine.commit_turn_request(
        engine,
        turn.Request(engine_turn.0, engine_turn.1, option.Some(deploy_card)),
      )

    engine
  })
}
