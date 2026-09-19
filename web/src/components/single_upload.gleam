import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_value(value: String) {
  attribute.property("value", json.string(value))
}

pub fn on_update(handler: fn(String) -> message) {
  event.on(
    "update",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-single-upload"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("value", {
      decode.string |> decode.map(PropsChangedValue)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(value: String)
}

fn init(_) {
  #(Model(value: ""), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedValue(String)
  OnUpdate(String)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedValue(new_value) -> {
      #(Model(value: new_value), effect.none())
    }

    OnUpdate(new_value) -> #(model, event.emit("input", json.string(new_value)))
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(_model: Model) {
  html.div([], [html.text("TODO")])
}
