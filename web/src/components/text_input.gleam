import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

const element_name = "components-text-input"

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

type Model {
  Model(value: String, type_: String)
}

// -----------------------------------------------------------------------------
// Message
// -----------------------------------------------------------------------------

type Msg {
  PropsChangedValue(String)
  PropsChangedType(String)
  OnInput(String)
  OnChange(String)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_property_change("value", {
        decode.string |> decode.map(PropsChangedValue)
      }),
      component.on_property_change("type_", {
        decode.string |> decode.map(PropsChangedType)
      }),
    ])

  lustre.register(component, element_name)
}

pub fn element(attrs: List(Attribute(msg))) -> Element(msg) {
  element.element(element_name, attrs, [])
}

// -----------------------------------------------------------------------------
// Properties
// -----------------------------------------------------------------------------

pub fn value(value: String) -> Attribute(msg) {
  attribute.property("value", json.string(value))
}

pub fn type_(type_: String) -> Attribute(msg) {
  attribute.property("type_", json.string(type_))
}

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

pub fn on_input(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on(
    "input",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

pub fn on_change(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on(
    "change",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(value: "", type_: "text"), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    PropsChangedValue(new_value) -> {
      #(Model(..model, value: new_value), effect.none())
    }

    PropsChangedType(new_type_) -> #(
      Model(..model, type_: new_type_),
      effect.none(),
    )

    OnInput(new_value) -> #(model, event.emit("input", json.string(new_value)))

    OnChange(new_value) -> #(
      model,
      event.emit("change", json.string(new_value)),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.input([
    attribute.class("px-2 py-1"),
    attribute.class("border rounded"),
    attribute.class("text-black"),
    attribute.value(model.value),
    attribute.type_(model.type_),
    event.on_input(OnInput),
    event.on_change(OnChange),
  ])
}
