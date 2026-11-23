import components/admonition
import components/button
import components/clipboard_copy
import components/field
import components/icon_button
import components/multi_select
import components/radio
import components/single_select
import components/text_area
import components/text_input
import components/text_link
import components/toggle

pub fn register() {
  let assert Ok(_) = admonition.register()
  let assert Ok(_) = button.register()
  let assert Ok(_) = clipboard_copy.register()
  let assert Ok(_) = field.register()
  let assert Ok(_) = icon_button.register()
  let assert Ok(_) = multi_select.register()
  let assert Ok(_) = radio.register()
  let assert Ok(_) = single_select.register()
  let assert Ok(_) = text_area.register()
  let assert Ok(_) = text_input.register()
  let assert Ok(_) = text_link.register()
  let assert Ok(_) = toggle.register()
}
