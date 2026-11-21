import gleam/dynamic/decode
import gleam/json
import gleam/list
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn disabled(disabled: Bool) {
  attribute.property("disabled", json.bool(disabled))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-icon-button"

pub fn element(
  attrs: List(Attribute(message)),
  children: List(Element(message)),
) {
  element.element(element_name, attrs, children)
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("class", {
      decode.string |> decode.map(PropsChangedClass)
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
  Model(class: String, disabled: Bool)
}

fn init(_) {
  #(Model(class: "", disabled: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedDisabled(Bool)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedDisabled(disabled) -> #(
      Model(..model, disabled:),
      effect.none(),
    )
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.button(
    list.flatten([
      [
        attribute.class(model.class),
        attribute.class("p-2"),
        attribute.class("flex justify-center items-center"),
        attribute.class("rounded-full"),
        attribute.class("text-(--march-950)"),
        attribute.type_("button"),
        attribute.disabled(model.disabled),
      ],
      case model.disabled {
        True -> []
        False -> [
          attribute.class("cursor-pointer"),
          attribute.class("hover:bg-(--march-200)"),
          attribute.class("active:bg-(--march-300)"),
        ]
      },
    ]),
    [component.default_slot([], [])],
  )
}
