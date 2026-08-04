import engine/card.{type Card}
import engine/classic.{type Classic}
import engine/unit.{type Unit}
import gleam/dict.{type Dict}
import gleam/option.{type Option}

pub type Model {
  Model(
    game: Classic,
    empty_board_moves: Dict(Int, List(#(Int, Int, Option(Unit)))),
    board_moves: Dict(Int, List(#(Int, Int, Option(Unit)))),
    board_marches: List(Int),
    hover_index: Option(Int),
  )
}

pub type Msg {
  PropsChangedGame(Classic)

  Hover(Int)
  Unhover
  Move(Int, Int)
  March(Int)
  Deploy(Card)
  Pass
  Undo
}
