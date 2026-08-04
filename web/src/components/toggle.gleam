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
// Model / Message
// -----------------------------------------------------------------------------

type Model {
  Model(value: Bool)
}

type Msg {
  PropsChangedValue(Bool)
  OnUpdate(Bool)
}

// -----------------------------------------------------------------------------
// Properties / Events
// -----------------------------------------------------------------------------

pub fn value(value: Bool) {
  attribute.property("value", json.bool(value))
}

pub fn on_update(handler: fn(Bool) -> msg) {
  event.on(
    "update",
    ["detail"] |> decode.at(decode.bool) |> decode.map(handler),
  )
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-toggle"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("value", {
      decode.bool |> decode.map(PropsChangedValue)
    }),
  ])
  |> lustre.register(element_name)
}

fn init(_) {
  #(Model(value: False), effect.none())
}

fn update(_model: Model, msg: Msg) {
  case msg {
    PropsChangedValue(value) -> {
      #(Model(value:), effect.none())
    }

    OnUpdate(value) -> #(Model(value:), event.emit("update", json.bool(value)))
  }
}

fn view(model: Model) {
  html.div(
    [
      attribute.class("w-12 h-6"),
      attribute.class("flex items-center"),
      attribute.class("rounded-full"),
      attribute.class("relative"),
      attribute.class("cursor-pointer"),
      attribute.class("transition-all"),
      case model.value {
        True -> attribute.class("bg-(--bg-on)")
        False -> attribute.class("bg-(--bg-off)")
      },
      event.on_click(OnUpdate(!model.value)),
    ],
    [
      html.div(
        [
          attribute.class("size-4"),
          attribute.class("absolute top-1/2 -translate-y-1/2"),
          attribute.class("bg-(--fg) rounded-full"),
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
