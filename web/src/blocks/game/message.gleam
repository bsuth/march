import engine.{type Engine}
import engine/card.{type Card}
import engine/color.{type Color}
import lib/theme.{type Theme}

pub type Message {
  Deploy(Card)
  EndTurn
  Hover(Int)
  Unhover
  Move(Int, Int)
  March(Int)
  PropsChangedColor(Color)
  PropsChangedEngine(Engine)
  PropsChangedTheme(Theme)
  Undo
}
