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

pub fn prop_autofocus(value: Bool) {
  attribute.property("autofocus", json.bool(value))
}

pub fn prop_type(type_: String) {
  attribute.property("type", json.string(type_))
}

pub fn prop_value(value: String) {
  attribute.property("value", json.string(value))
}

pub fn on_change(handler: fn(String) -> message) {
  event.on(
    "change",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

pub fn on_input(handler: fn(String) -> message) {
  event.on(
    "input",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

pub fn on_submit(message: message) {
  // Lustre handles the "submit" event exceptionally, so we have to use
  // "submit_" instead.
  event.on("submit_", decode.success(message))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-text-input"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("autofocus", {
      decode.bool |> decode.map(PropsChangedAutofocus)
    }),
    component.on_property_change("type", {
      decode.string |> decode.map(PropsChangedType)
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
  Model(autofocus: Bool, type_: String, value: String)
}

fn init(_) {
  #(Model(autofocus: False, type_: "text", value: ""), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedAutofocus(Bool)
  PropsChangedType(String)
  PropsChangedValue(String)
  OnChange(String)
  OnInput(String)
  OnKeypress(String)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedAutofocus(autofocus) -> #(
      Model(..model, autofocus:),
      effect.none(),
    )
    PropsChangedType(type_) -> #(Model(..model, type_:), effect.none())
    PropsChangedValue(value) -> {
      #(Model(..model, value:), effect.none())
    }

    OnChange(value) -> #(
      Model(..model, value:),
      event.emit("change", json.string(value)),
    )
    OnInput(value) -> #(
      Model(..model, value:),
      event.emit("input", json.string(value)),
    )
    OnKeypress(value) -> {
      case value {
        "Enter" -> #(model, event.emit("submit_", json.null()))
        _ -> #(model, effect.none())
      }
    }
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.input([
    attribute.autofocus(model.autofocus),
    attribute.class("w-full px-2 py-1"),
    attribute.class("ring"),
    attribute.class("outline-none"),
    attribute.class("focus:ring-2"),
    attribute.type_(model.type_),
    attribute.value(model.value),
    event.on_change(OnChange),
    event.on_input(OnInput),
    event.on_keypress(OnKeypress),
  ])
}
