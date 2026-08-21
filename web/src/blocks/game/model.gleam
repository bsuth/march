import engine.{type Engine}
import engine/color.{type Color}
import gleam/option.{type Option}
import lib/theme.{type Theme}

pub type Model {
  Model(color: Color, engine: Engine, hover_index: Option(Int), theme: Theme)
}
