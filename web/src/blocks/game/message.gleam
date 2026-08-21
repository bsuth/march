import engine.{type Engine}
import engine/card.{type Card}
import engine/color.{type Color}
import lib/theme.{type Theme}

pub type Message {
  PropsChangedColor(Color)
  PropsChangedEngine(Engine)
  PropsChangedTheme(Theme)
  Hover(Int)
  Unhover
  Move(Int, Int)
  March(Int)
  Deploy(Card)
  Pass
  Undo
}
