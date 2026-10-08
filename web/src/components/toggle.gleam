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
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_disabled(disabled: Bool) {
  attribute.property("disabled", json.bool(disabled))
}

pub fn prop_value(value: Bool) {
  attribute.property("value", json.bool(value))
}

pub fn on_update(handler: fn(Bool) -> message) {
  event.on(
    "update",
    ["detail"] |> decode.at(decode.bool) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-toggle"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("disabled", {
      decode.bool |> decode.map(PropsChangedDisabled)
    }),
    component.on_property_change("value", {
      decode.bool |> decode.map(PropsChangedValue)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(disabled: Bool, value: Bool)
}

fn init(_) {
  #(Model(disabled: False, value: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedDisabled(Bool)
  PropsChangedValue(Bool)

  OnUpdate(Bool)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedDisabled(disabled) -> #(
      Model(..model, disabled:),
      effect.none(),
    )
    PropsChangedValue(value) -> #(Model(..model, value:), effect.none())

    OnUpdate(value) -> #(
      Model(..model, value:),
      event.emit("update", json.bool(value)),
    )
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.div(
    [
      attribute.class("w-12 h-6"),
      attribute.class("flex items-center"),
      attribute.class("rounded-full"),
      attribute.class("relative"),
      attribute.class("cursor-pointer"),
      attribute.class("transition-all"),
      attribute.class("bg-(--march-50)"),
      case model.value {
        True -> attribute.class("bg-(--march-800)")
        False -> attribute.class("bg-(--march-400)")
      },
      attribute.disabled(model.disabled),
      event.on_click(OnUpdate(!model.value)),
    ],
    [
      html.div(
        [
          attribute.class("size-4"),
          attribute.class("absolute top-1/2 -translate-y-1/2"),
          attribute.class("bg-(--march-50)"),
          attribute.class("rounded-full"),
          attribute.class("transition-all"),
          case model.value {
            True -> attribute.class("left-7")
            False -> attribute.class("left-1")
          },
        ],
        [],
      ),
    ],
  )
}
