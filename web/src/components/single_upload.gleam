import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

const element_name = "components-single-upload"

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

type Model {
  Model(value: String)
}

// -----------------------------------------------------------------------------
// Message
// -----------------------------------------------------------------------------

type Msg {
  PropsChangedValue(String)
  OnUpdate(String)
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

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

pub fn on_update(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on(
    "update",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(value: ""), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    PropsChangedValue(new_value) -> {
      #(Model(value: new_value), effect.none())
    }

    OnUpdate(new_value) -> #(model, event.emit("input", json.string(new_value)))
  }
}

fn view(_model: Model) -> Element(Msg) {
  html.div([], [html.text("TODO")])
}
