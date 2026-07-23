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
  Model(href: String)
}

type Msg {
  PropsChangedHref(String)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn href(value: String) {
  attribute.property("href", json.string(value))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-text-link"

pub fn element(attrs: List(Attribute(msg)), children: List(Element(msg))) {
  element.element(element_name, attrs, children)
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("href", {
      decode.string |> decode.map(PropsChangedHref)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(href: "/"), effect.none())
}

fn update(_model: Model, msg: Msg) {
  case msg {
    PropsChangedHref(href) -> #(Model(href:), effect.none())
  }
}

fn view(model: Model) {
  html.a(
    [
      attribute.class("text-(--text)"),
      attribute.class("hover:text-(--text-hover)"),
      attribute.href(model.href),
    ],
    [
      component.default_slot([], []),
    ],
  )
}
