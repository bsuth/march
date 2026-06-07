import components/button
import components/field
import components/float_input
import components/int_input
import components/location_input
import components/multi_select
import components/multi_upload
import components/radio
import components/single_select
import components/single_upload
import components/text_area
import components/text_input
import components/text_link
import components/toggle

pub fn register() {
  let assert Ok(_) = button.register()
  let assert Ok(_) = field.register()
  let assert Ok(_) = float_input.register()
  let assert Ok(_) = int_input.register()
  let assert Ok(_) = location_input.register()
  let assert Ok(_) = multi_select.register()
  let assert Ok(_) = multi_upload.register()
  let assert Ok(_) = radio.register()
  let assert Ok(_) = single_select.register()
  let assert Ok(_) = single_upload.register()
  let assert Ok(_) = text_area.register()
  let assert Ok(_) = text_input.register()
  let assert Ok(_) = text_link.register()
  let assert Ok(_) = toggle.register()
}
