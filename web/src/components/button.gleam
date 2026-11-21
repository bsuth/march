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

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn disabled(disabled: Bool) {
  attribute.property("disabled", json.bool(disabled))
}

pub fn loading(loading: Bool) {
  attribute.property("loading", json.bool(loading))
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
    component.on_property_change("class", {
      decode.string |> decode.map(PropsChangedClass)
    }),
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
  Model(class: String, disabled: Bool, loading: Bool)
}

fn init(_) {
  #(Model(class: "", disabled: False, loading: False), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedDisabled(Bool)
  PropsChangedLoading(Bool)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())

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
      attribute.class(model.class),
      attribute.class("px-4 py-2"),
      attribute.class("flex justify-center items-center gap-2"),
      attribute.class("bg-(--march-800)"),
      attribute.class("text-(--march-50)"),
      attribute.class("font-bold"),
      attribute.class("cursor-pointer"),
      attribute.class("not-disabled:hover:bg-(--march-700)"),
      attribute.class("not-disabled:active:bg-(--march-600)"),
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
