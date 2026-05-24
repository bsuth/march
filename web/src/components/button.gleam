import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import phosphor

const element_name = "components-button"

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

type Model {
  Model(loading: Bool)
}

// -----------------------------------------------------------------------------
// Message
// -----------------------------------------------------------------------------

type Msg {
  PropsChangedLoading(Bool)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_property_change("loading", {
        decode.bool |> decode.map(PropsChangedLoading)
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

pub fn on_click(msg: msg) -> Attribute(msg) {
  event.on_click(msg)
}

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
  #(Model(loading: False), effect.none())
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    PropsChangedLoading(new_loading) -> #(
      Model(loading: new_loading),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.button(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex gap-2 items-center"),
      attribute.class("bg-blue-700 rounded"),
      attribute.class("text-white font-semibold"),
      attribute.class("cursor-pointer"),
      attribute.class("hover:bg-blue-600"),
      attribute.class("active:bg-blue-500"),
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
