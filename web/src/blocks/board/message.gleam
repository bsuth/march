import engine/board.{type Board}
import engine/color.{type Color}
import lib/theme.{type Theme}

pub type Message {
  PropsChangedBoard(Board)
  PropsChangedColor(Color)
  PropsChangedTheme(Theme)
}
