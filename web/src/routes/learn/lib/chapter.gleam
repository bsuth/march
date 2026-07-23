pub type Chapter {
  Setup
  Gameplay
  MovingCards
  CapturingCards
  Conclusion
  NotFound
}

pub const order = [
  Setup,
  Gameplay,
  MovingCards,
  CapturingCards,
  Conclusion,
]

pub fn get_title(chapter: Chapter) {
  case chapter {
    Setup -> "Setup"
    Gameplay -> "Gameplay"
    MovingCards -> "Moving Cards"
    CapturingCards -> "Capturing Cards"
    Conclusion -> "Conclusion"
    NotFound -> "Not Found"
  }
}
