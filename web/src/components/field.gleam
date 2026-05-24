import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

const element_name = "components-field"

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

type Model {
  Model(label: String)
}

// -----------------------------------------------------------------------------
// Message
// -----------------------------------------------------------------------------

type Msg {
  PropsChangedLabel(String)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_property_change("label", {
        decode.string |> decode.map(PropsChangedLabel)
      }),
    ])

  lustre.register(component, element_name)
}

pub fn element(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element.element(element_name, attrs, children)
}

// -----------------------------------------------------------------------------
// Properties
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(label: ""), effect.none())
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    PropsChangedLabel(new_label) -> #(Model(new_label), effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("flex flex-col gap-1")], [
    html.label([], [html.text(model.label)]),
    component.default_slot([], []),
  ])
}
