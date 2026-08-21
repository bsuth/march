import blocks/board/init
import blocks/board/message
import blocks/board/update
import blocks/board/view
import engine/board.{type Board}
import engine/color.{type Color}
import gleam/dynamic/decode
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/element

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn board(board: Board) {
  attribute.property("board", board.json(board))
}

pub fn theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

pub fn color(color: Color) {
  attribute.property("color", color.json(color))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-board"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(fn(_) { init.init() }, update.update, view.view, [
    component.on_property_change("board", {
      board.decoder() |> decode.map(message.PropsChangedBoard)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(message.PropsChangedTheme)
    }),
    component.on_property_change("color", {
      color.decoder() |> decode.map(message.PropsChangedColor)
    }),
  ])
  |> lustre.register(element_name)
}
