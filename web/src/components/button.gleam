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
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_disabled(value: Bool) {
  attribute.property("disabled", json.bool(value))
}

pub fn prop_loading(value: Bool) {
  attribute.property("loading", json.bool(value))
}

pub fn on_click(message: message) -> Attribute(message) {
  event.on_click(message)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(disabled: Bool, loading: Bool)
}

fn init(_) {
  #(Model(disabled: False, loading: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedDisabled(Bool)
  PropsChangedLoading(Bool)
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

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.button(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex gap-2 items-center"),
      attribute.class(
        "bg-[light-dark(var(--color-zinc-800),var(--color-zinc-100))]",
      ),
      attribute.class("rounded"),
      attribute.class(
        "text-[light-dark(var(--color-white),var(--color-black))]",
      ),
      attribute.class("font-bold"),
      attribute.class("cursor-pointer"),
      attribute.class("disabled:cursor-not-allowed disabled:opacity-70"),
      attribute.class(
        "not-disabled:hover:bg-[light-dark(var(--color-zinc-700),var(--color-zinc-200))]",
      ),
      attribute.class(
        "not-disabled:active:bg-[light-dark(var(--color-zinc-600),var(--color-zinc-300))]",
      ),
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
