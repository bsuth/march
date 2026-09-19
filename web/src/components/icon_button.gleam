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
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_disabled(value: Bool) {
  attribute.property("disabled", json.bool(value))
}

pub fn on_click(message: message) -> Attribute(message) {
  event.on_click(message)
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
  Model(disabled: Bool)
}

fn init(_) {
  #(Model(disabled: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedDisabled(Bool)
}

fn update(_model: Model, message: Message) {
  case message {
    PropsChangedDisabled(new_disabled) -> #(
      Model(disabled: new_disabled),
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
        attribute.class("p-2"),
        attribute.class("flex justify-center items-center"),
        attribute.class("rounded-full"),
        attribute.class(
          "text-[light-dark(var(--color-black),var(--color-white))]",
        ),
        attribute.type_("button"),
        attribute.disabled(model.disabled),
      ],
      case model.disabled {
        True -> []
        False -> [
          attribute.class("cursor-pointer"),
          attribute.class(
            "hover:bg-[light-dark(var(--color-zinc-200),var(--color-zinc-700))]",
          ),
          attribute.class(
            "active:bg-[light-dark(var(--color-zinc-300),var(--color-zinc-800))]",
          ),
        ]
      },
    ]),
    [component.default_slot([], [])],
  )
}
