import lustre
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import routes/cheatsheet/x.{type Model, type Msg}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "routes-cheatsheet"

pub fn register() -> Result(Nil, lustre.Error) {
  let component = lustre.component(init, update, view, [])
  lustre.register(component, element_name)
}

pub fn element(attrs: List(Attribute(msg))) -> Element(msg) {
  element.element(element_name, attrs, [])
}

// -----------------------------------------------------------------------------
// Properties
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Events
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Lifecycle
// -----------------------------------------------------------------------------

fn init(_) -> #(Model, Effect(Msg)) {
  #(x.Model(foo: 0), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    x.PrevChapter -> #(model, effect.none())
    x.NextChapter -> #(model, effect.none())
  }
}

fn view(_model: Model) -> Element(Msg) {
  html.div([attribute.class("")], [html.text("hello world")])
}
