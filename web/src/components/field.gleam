import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html

// -----------------------------------------------------------------------------
// Model / Message
// -----------------------------------------------------------------------------

type Model {
  Model(label: String)
}

type Msg {
  PropsChangedLabel(String)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn label(label: String) {
  attribute.property("label", json.string(label))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-field"

pub fn element(attrs: List(Attribute(msg)), children: List(Element(msg))) {
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

fn init(_) {
  #(Model(label: ""), effect.none())
}

fn update(_model: Model, msg: Msg) {
  case msg {
    PropsChangedLabel(new_label) -> #(Model(new_label), effect.none())
  }
}

fn view(model: Model) {
  html.div([attribute.class("flex flex-col gap-1")], [
    html.label([], [
      component.named_slot("label", [], [html.text(model.label)]),
    ]),
    component.default_slot([], []),
  ])
}
