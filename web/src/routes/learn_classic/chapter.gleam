import gleam/list

pub type Chapter {
  Introduction
  Deck
  Board
}

pub const list = [
  Introduction,
  Deck,
  Board,
]

pub fn to_string(chapter: Chapter) {
  case chapter {
    Introduction -> "introduction"
    Deck -> "deck"
    Board -> "board"
  }
}

pub fn from_string(chapter_string: String) {
  case chapter_string {
    "introduction" -> Ok(Introduction)
    "board" -> Ok(Board)
    "deck" -> Ok(Deck)
    _ -> Error(Nil)
  }
}

pub fn title(chapter: Chapter) {
  case chapter {
    Introduction -> "Introduction"
    Deck -> "Deck"
    Board -> "Board"
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
