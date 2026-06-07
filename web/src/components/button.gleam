import gleam/dynamic/decode
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
  Model(loading: Bool)
}

type Msg {
  PropsChangedLoading(Bool)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn on_click(msg: msg) -> Attribute(msg) {
  event.on_click(msg)
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "components-button"

pub fn element(attrs: List(Attribute(msg)), children: List(Element(msg))) {
  element.element(element_name, attrs, children)
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("loading", {
      decode.bool |> decode.map(PropsChangedLoading)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(loading: False), effect.none())
}

fn update(_model: Model, msg: Msg) {
  case msg {
    PropsChangedLoading(new_loading) -> #(
      Model(loading: new_loading),
      effect.none(),
    )
  }
}

fn view(model: Model) {
  html.button(
    [
      attribute.class("px-4 py-2"),
      attribute.class("flex gap-2 items-center"),
      attribute.class("bg-blue-600 rounded"),
      attribute.class("text-white font-semibold"),
      attribute.class("cursor-pointer"),
      attribute.class("hover:bg-blue-700"),
      attribute.class("active:bg-blue-800"),
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
