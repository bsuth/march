import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor

// -----------------------------------------------------------------------------
// Model / Message
// -----------------------------------------------------------------------------

type Model {
  Model(disabled: Bool, loading: Bool)
}

type Message {
  PropsChangedDisabled(Bool)
  PropsChangedLoading(Bool)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn disabled(value: Bool) {
  attribute.property("disabled", json.bool(value))
}

pub fn loading(value: Bool) {
  attribute.property("loading", json.bool(value))
}

pub fn on_click(message: message) -> Attribute(message) {
  event.on_click(message)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

// NOTE: If this is changed, it must be synced with `button.css`.
const element_name = "march-button"

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
    component.on_property_change("loading", {
      decode.bool |> decode.map(PropsChangedLoading)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(disabled: False, loading: False), effect.none())
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedDisabled(disabled) -> #(
      Model(..model, disabled:),
      effect.none(),
    )

    PropsChangedLoading(loading) -> #(Model(..model, loading:), effect.none())
  }
}

fn view(model: Model) {
  html.button(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex gap-2 items-center"),
      attribute.class("rounded"),
      attribute.class("text-(--text) font-bold"),
      attribute.class("bg-(--bg)"),
      attribute.class("not-disabled:hover:bg-(--bg-hover)"),
      attribute.class("not-disabled:active:bg-(--bg-active)"),
      attribute.class("cursor-pointer"),
      attribute.class("disabled:cursor-not-allowed disabled:opacity-70"),
      attribute.disabled(model.disabled),
      attribute.type_("button"),
    ],
    [
      case model.loading {
        True -> phosphor.circle_notch_bold([attribute.class("animate-spin")])
        False -> element.none()
      },
      component.default_slot([], []),
    ],
  )
}
