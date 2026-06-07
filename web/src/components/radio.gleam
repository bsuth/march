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
  Model(value: String)
}

type Msg {
  PropsChangedValue(String)
  OnUpdate(String)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn value(value: String) {
  attribute.property("value", json.string(value))
}

pub fn on_update(handler: fn(String) -> msg) {
  event.on(
    "update",
    ["detail"] |> decode.at(decode.string) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "components-radio"

pub fn element(attrs: List(Attribute(msg))) {
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

fn init(_) {
  #(Model(value: ""), effect.none())
}

fn update(model: Model, msg: Msg) {
  case msg {
    PropsChangedValue(new_value) -> {
      #(Model(value: new_value), effect.none())
    }

    OnUpdate(new_value) -> #(
      model,
      event.emit("update", json.string(new_value)),
    )
  }
}

fn view(_model: Model) {
  html.div([], [html.text("TODO")])
}
