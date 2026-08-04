import components/icon_button
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/effect
import lustre/element
import lustre/event
import phosphor

// -----------------------------------------------------------------------------
// Model / Message
// -----------------------------------------------------------------------------

type Model =
  Theme

type Msg {
  ToggleTheme
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "theme-toggle"

pub fn element(attrs: List(Attribute(msg))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [])
  |> lustre.register(element_name)
}

fn init(_) {
  let model = theme.get()
  theme.apply(model)
  #(model, effect.none())
}

fn update(model: Model, msg: Msg) {
  case msg {
    ToggleTheme -> {
      let new_model = case model {
        theme.Light -> theme.Dark
        theme.Dark -> theme.Light
      }

      theme.apply(new_model)
      theme.save(new_model)
      #(new_model, effect.none())
    }
  }
}

fn view(model: Model) {
  icon_button.element([event.on_click(ToggleTheme)], [
    case model {
      theme.Light -> phosphor.sun_fill([attribute.class("size-6")])
      theme.Dark -> phosphor.moon_fill([attribute.class("size-6")])
    },
  ])
}
