import components/icon_button
import gleam/dynamic/decode
import gleam/javascript/promise
import gleam/json
import lib/js
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
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

pub fn value(value: String) {
  attribute.property("value", json.string(value))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-clipboard-copy"

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
    component.on_property_change("value", {
      decode.string |> decode.map(PropsChangedValue)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(class: String, copied: Bool, disabled: Bool, value: String)
}

fn init(_) {
  #(Model(class: "", copied: False, disabled: False, value: ""), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedDisabled(Bool)
  PropsChangedValue(String)

  CopyValueToClipboard
  SetCopied(Bool)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedDisabled(disabled) -> #(
      Model(..model, disabled:),
      effect.none(),
    )
    PropsChangedValue(value) -> #(Model(..model, value:), effect.none())

    CopyValueToClipboard -> #(
      model,
      effect.from(fn(dispatch) {
        model.value
        |> js.navigator_clipboard_write_text()
        |> promise.tap(fn(_) { dispatch(SetCopied(True)) })
        Nil
      }),
    )
    SetCopied(copied) -> #(Model(..model, copied:), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  icon_button.element(
    [
      attribute.class(model.class),
      attribute.class("relative"),
      event.on_mouse_enter(SetCopied(False)),
      icon_button.disabled(model.disabled),
      case model.disabled {
        True -> attribute.none()
        False -> event.on_click(CopyValueToClipboard)
      },
    ],
    [
      case model.copied {
        True ->
          phosphor.check_regular([
            attribute.class("size-8 text-(--march-success)"),
          ])
        False -> phosphor.copy_regular([attribute.class("size-8")])
      },
    ],
  )
}
