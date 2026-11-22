import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import phosphor

pub type Variant {
  Danger
  Note
  Success
  Tip
  Warning
}

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn variant(variant: Variant) {
  attribute.property("variant", case variant {
    Danger -> json.string("danger")
    Note -> json.string("note")
    Success -> json.string("success")
    Tip -> json.string("tip")
    Warning -> json.string("warning")
  })
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-admonition"

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
    component.on_property_change(
      "variant",
      decode.string
        |> decode.then(fn(variant_string) {
          case variant_string {
            "danger" -> decode.success(Danger)
            "note" -> decode.success(Note)
            "success" -> decode.success(Success)
            "tip" -> decode.success(Tip)
            "warning" -> decode.success(Warning)
            _ -> decode.failure(Note, "variant")
          }
        })
        |> decode.map(PropsChangedVariant),
    ),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(class: String, variant: Variant)
}

fn init(_) {
  #(Model(class: "", variant: Note), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

type Message {
  PropsChangedClass(String)
  PropsChangedVariant(Variant)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
    PropsChangedVariant(variant) -> #(Model(..model, variant:), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let #(title, icon) = case model.variant {
    Danger -> #("Danger", phosphor.warning_regular)
    Note -> #("Note", phosphor.info_regular)
    Success -> #("Success", phosphor.check_circle_regular)
    Tip -> #("Tip", phosphor.lightbulb_regular)
    Warning -> #("Warning", phosphor.warning_circle_regular)
  }

  html.div(
    [
      attribute.class(model.class),
      attribute.class("p-3"),
      attribute.class("flex flex-col gap-2"),
      attribute.class("border-l-8"),
      case model.variant {
        Danger ->
          attribute.class("bg-(--march-danger)/10 border-(--march-danger)")
        Note -> attribute.class("bg-(--march-info)/10 border-(--march-info)")
        Success ->
          attribute.class("bg-(--march-success)/10 border-(--march-success)")
        Tip ->
          attribute.class(" bg-(--march-primary)/10 border-(--march-primary)")
        Warning ->
          attribute.class("bg-(--march-warning)/10 border-(--march-warning)")
      },
    ],
    [
      html.div(
        [
          attribute.class("flex items-center gap-2"),
          case model.variant {
            Danger -> attribute.class("text-(--march-danger)")
            Note -> attribute.class("text-(--march-info)")
            Success -> attribute.class("text-(--march-success)")
            Tip -> attribute.class("text-(--march-primary)")
            Warning -> attribute.class("text-(--march-warning)")
          },
        ],
        [
          icon([attribute.class("size-6")]),
          html.h6([], [html.text(title)]),
        ],
      ),
      component.default_slot([], []),
    ],
  )
}
