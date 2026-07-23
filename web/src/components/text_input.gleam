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
// Model / Message
// -----------------------------------------------------------------------------

type Model {
  Model(value: String, type_: String)
}

type Msg {
  PropsChangedValue(String)
  PropsChangedType(String)
  OnInput(String)
  OnChange(String)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn value(value: String) {
  attribute.property("value", json.string(value))
}

pub fn type_(type_: String) {
  attribute.property("type_", json.string(type_))
}

pub fn on_input(handler: fn(String) -> msg) {
  event.on(
    "input",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

pub fn on_change(handler: fn(String) -> msg) {
  event.on(
    "change",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-text-input"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("value", {
      decode.string |> decode.map(PropsChangedValue)
    }),
    component.on_property_change("type_", {
      decode.string |> decode.map(PropsChangedType)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(value: "", type_: "text"), effect.none())
}

fn update(model: Model, msg: Msg) {
  case msg {
    PropsChangedValue(new_value) -> {
      #(Model(..model, value: new_value), effect.none())
    }

    PropsChangedType(new_type_) -> #(
      Model(..model, type_: new_type_),
      effect.none(),
    )

    OnInput(value) -> #(
      Model(..model, value:),
      event.emit("input", json.string(value)),
    )

    OnChange(value) -> #(
      Model(..model, value:),
      event.emit("change", json.string(value)),
    )
  }
}

fn view(model: Model) {
  html.input([
    attribute.class("w-full px-2 py-1"),
    attribute.class("ring rounded"),
    attribute.class("outline-none"),
    attribute.class("focus:ring-2"),
    attribute.value(model.value),
    attribute.type_(model.type_),
    event.on_input(OnInput),
    event.on_change(OnChange),
  ])
}
