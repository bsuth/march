import engine/board.{type Board}
import engine/color.{type Color}
import lib/theme.{type Theme}

pub type Model {
  Model(board: Board, color: Color, theme: Theme)
}
