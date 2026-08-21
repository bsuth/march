import components/icon_button
import lib/theme
import lustre/attribute
import lustre/event
import main/message
import main/model.{type Model}
import phosphor

pub fn theme_view(model: Model) {
  let app = model.get_app(model)

  icon_button.element([event.on_click(message.ToggleTheme)], [
    case app.theme {
      theme.Light -> phosphor.sun_fill([attribute.class("size-6")])
      theme.Dark -> phosphor.moon_fill([attribute.class("size-6")])
    },
  ])
}
