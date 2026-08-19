import gleam/option.{type Option}
import new_engine/card.{type Card}
import new_engine/color.{type Color}
import new_engine/turn/march.{type March}
import new_engine/turn/move.{type Move}

pub type Turn {
  Turn(color: Color, move: Move, marches: List(March), deploy: Option(Card))
  Pass
}
