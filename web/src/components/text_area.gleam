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

pub fn on_input(handler: fn(String) -> message) {
  event.on(
    "input",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

pub fn on_change(handler: fn(String) -> message) {
  event.on(
    "change",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-text-area"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("class", {
      decode.string |> decode.map(PropsChangedClass)
    }),
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
  OnInput(String)
  OnChange(String)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedValue(new_value) -> {
      #(Model(..model, value: new_value), effect.none())
    }

    OnInput(new_value) -> #(model, event.emit("input", json.string(new_value)))
    OnChange(new_value) -> #(
      model,
      event.emit("change", json.string(new_value)),
    )
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.textarea(
    [
      attribute.class(model.class),
      attribute.class("px-2 py-1"),
      attribute.class("border rounded"),
      attribute.class("text-black"),
      event.on_input(OnInput),
      event.on_change(OnChange),
    ],
    model.value,
  )
}
