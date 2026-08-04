import gleam/dynamic/decode
import gleam/json
import gleam/list
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

// -----------------------------------------------------------------------------
// Model / Message
// -----------------------------------------------------------------------------

type Model {
  Model(disabled: Bool)
}

type Message {
  PropsChangedDisabled(Bool)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn disabled(value: Bool) {
  attribute.property("disabled", json.bool(value))
}

pub fn on_click(message: message) -> Attribute(message) {
  event.on_click(message)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

// NOTE: If this is changed, it must be synced with `icon_button.css`.
const element_name = "march-icon-button"

pub fn element(
  attrs: List(Attribute(message)),
  children: List(Element(message)),
) {
  element.element(element_name, attrs, children)
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("disabled", {
      decode.bool |> decode.map(PropsChangedDisabled)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(disabled: False), effect.none())
}

fn update(_model: Model, message: Message) {
  case message {
    PropsChangedDisabled(new_disabled) -> #(
      Model(disabled: new_disabled),
      effect.none(),
    )
  }
}

fn view(model: Model) {
  html.button(
    list.flatten([
      [
        attribute.class("p-2"),
        attribute.class("flex justify-center items-center"),
        attribute.class("text-(--text)"),
        attribute.class("rounded-full"),
        attribute.type_("button"),
        attribute.disabled(model.disabled),
      ],
      case model.disabled {
        True -> []
        False -> [
          attribute.class("hover:bg-(--bg-hover) active:bg-(--bg-active)"),
          attribute.class("cursor-pointer"),
        ]
      },
    ]),
    [component.default_slot([], [])],
  )
}
