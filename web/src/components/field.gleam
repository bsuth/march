import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_label(label: String) {
  attribute.property("label", json.string(label))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-field"

pub fn element(
  attrs: List(Attribute(message)),
  children: List(Element(message)),
) {
  element.element(element_name, attrs, children)
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("label", {
      decode.string |> decode.map(PropsChangedLabel)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(label: String)
}

fn init(_) {
  #(Model(label: ""), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedLabel(String)
}

fn update(_model: Model, message: Message) {
  case message {
    PropsChangedLabel(new_label) -> #(Model(new_label), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.div([attribute.class("flex flex-col gap-1")], [
    html.label([], [
      component.named_slot("label", [], [html.text(model.label)]),
    ]),
    component.default_slot([], []),
  ])
}
