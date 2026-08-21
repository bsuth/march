import blocks/game/init
import blocks/game/message
import blocks/game/update
import blocks/game/view
import engine.{type Engine}
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

pub fn color(color: Color) {
  attribute.property("color", color.json(color))
}

pub fn engine(engine: Engine) {
  attribute.property("engine", engine.json(engine))
}

pub fn theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-game"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(fn(_) { init.init() }, update.update, view.view, [
    component.on_property_change("color", {
      color.decoder() |> decode.map(message.PropsChangedColor)
    }),
    component.on_property_change("engine", {
      engine.decoder() |> decode.map(message.PropsChangedEngine)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(message.PropsChangedTheme)
    }),
  ])
  |> lustre.register(element_name)
}
