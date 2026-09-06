import blocks/card/init
import blocks/card/message
import blocks/card/update
import blocks/card/view
import engine/card.{type Card}
import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/element

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn value(card: Card) {
  attribute.property("value", card.json(card))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-card"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(fn(_) { init.init() }, update.update, view.view, [
    component.on_property_change("value", {
      card.decoder() |> decode.map(message.PropsChangedCard)
    }),
  ])
  |> lustre.register(element_name)
}
