import gleam/list

pub type Chapter {
  Introduction
  Deck
  Board
  Turn
  Leading
  Marching
  Deploying
  Capturing
  Winning
  Conclusion
}

pub const list = [
  Introduction,
  Deck,
  Board,
  Turn,
  Leading,
  Marching,
  Deploying,
  Capturing,
  Winning,
  Conclusion,
]

pub fn to_string(chapter: Chapter) {
  case chapter {
    Introduction -> "introduction"
    Deck -> "deck"
    Board -> "board"
    Turn -> "turn"
    Leading -> "leading"
    Marching -> "marching"
    Deploying -> "deploying"
    Capturing -> "capturing"
    Winning -> "winning"
    Conclusion -> "conclusion"
  }
}

pub fn from_string(chapter_string: String) {
  case chapter_string {
    "introduction" -> Ok(Introduction)
    "deck" -> Ok(Deck)
    "board" -> Ok(Board)
    "turn" -> Ok(Turn)
    "leading" -> Ok(Leading)
    "marching" -> Ok(Marching)
    "deploying" -> Ok(Deploying)
    "capturing" -> Ok(Capturing)
    "winning" -> Ok(Winning)
    "conclusion" -> Ok(Conclusion)
    _ -> Error(Nil)
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
