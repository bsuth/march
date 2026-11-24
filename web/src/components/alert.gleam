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
  Info
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
    Info -> json.string("note")
    Success -> json.string("success")
    Tip -> json.string("tip")
    Warning -> json.string("warning")
  })
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "march-alert"

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
            "note" -> decode.success(Info)
            "success" -> decode.success(Success)
            "tip" -> decode.success(Tip)
            "warning" -> decode.success(Warning)
            _ -> decode.failure(Info, "variant")
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
  #(Model(class: "", variant: Info), effect.none())
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
  let icon = case model.variant {
    Danger -> phosphor.warning_regular
    Info -> phosphor.info_regular
    Success -> phosphor.check_circle_regular
    Tip -> phosphor.lightbulb_regular
    Warning -> phosphor.warning_circle_regular
  }

  html.div(
    [
      attribute.class(model.class),
      attribute.class("p-2"),
      attribute.class("flex items-center gap-2"),
      attribute.class("border"),
      attribute.class(case model.variant {
        Danger ->
          "text-(--march-danger) bg-(--march-danger)/10 border-(--march-danger)"
        Info -> "text-(--march-info) bg-(--march-info)/10 border-(--march-info)"
        Success ->
          "text-(--march-success) bg-(--march-success)/10 border-(--march-success)"
        Tip ->
          "text-(--march-primary) bg-(--march-primary)/10 border-(--march-primary)"
        Warning ->
          "text-(--march-warning) bg-(--march-warning)/10 border-(--march-warning)"
      }),
    ],
    [
      icon([attribute.class("size-6")]),
      component.default_slot([], []),
    ],
  )
}
