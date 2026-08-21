import blocks/board/model.{Model}
import engine/board
import engine/color
import lib/theme
import lustre/effect

pub fn init() {
  #(
    Model(board.new(4, 4), color: color.Black, theme: theme.Light),
    effect.none(),
  )
}
