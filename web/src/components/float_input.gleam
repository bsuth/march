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

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn value(value: String) {
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

const element_name = "march-float-input"

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
  Model(class: String, value: String)
}

fn init(_) {
  #(Model(class: "", value: ""), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedValue(String)
  OnUpdate(String)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedValue(value) -> #(Model(..model, value:), effect.none())

    OnUpdate(new_value) -> #(
      model,
      event.emit("update", json.string(new_value)),
    )
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.div([attribute.class(model.class)], [
    html.text("TODO"),
  ])
}
