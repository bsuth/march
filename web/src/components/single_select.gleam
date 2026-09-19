import gleam/dynamic/decode
import gleam/json
import gleam/list
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

pub fn prop_options(options: List(#(String, String))) {
  attribute.property(
    "options",
    json.array(options, fn(option) {
      json.object([
        #("value", json.string(option.0)),
        #("label", json.string(option.1)),
      ])
    }),
  )
}

pub fn prop_disabled(disabled: Bool) {
  attribute.property("disabled", json.bool(disabled))
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

const element_name = "march-single-select"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("value", {
      decode.string |> decode.map(PropsChangedValue)
    }),
    component.on_property_change("options", {
      {
        use value <- decode.field("value", decode.string)
        use label <- decode.field("label", decode.string)
        decode.success(#(value, label))
      }
      |> decode.list()
      |> decode.map(PropsChangedOptions)
    }),
    component.on_property_change("disabled", {
      decode.bool |> decode.map(PropsChangedDisabled)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(value: String, options: List(#(String, String)), disabled: Bool)
}

fn init(_) {
  #(Model(value: "", options: [], disabled: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  OnChange(String)
  PropsChangedDisabled(Bool)
  PropsChangedOptions(List(#(String, String)))
  PropsChangedValue(String)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedDisabled(new_disabled) -> #(
      Model(..model, disabled: new_disabled),
      effect.none(),
    )

    PropsChangedOptions(new_options) -> #(
      Model(..model, options: new_options),
      effect.none(),
    )

    PropsChangedValue(new_value) -> #(
      Model(..model, value: new_value),
      effect.none(),
    )

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
  html.select(
    [
      attribute.class("p-2"),
      attribute.class("border rounded"),
      attribute.class("cursor-pointer outline-none"),
      attribute.class("disabled:opacity-70 disabled:cursor-not-allowed"),
      attribute.value(model.value),
      attribute.disabled(model.disabled),
      event.on_change(OnChange),
    ],
    list.map(model.options, fn(option) {
      html.option([attribute.value(option.0)], option.1)
    }),
  )
}
