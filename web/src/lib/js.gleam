import gleam/javascript/promise.{type Promise}

@external(javascript, "./js.js", "navigator_clipboard_write_text")
pub fn navigator_clipboard_write_text(text: String) -> Promise(Nil)

@external(javascript, "./js.js", "window_location_host")
pub fn window_location_host() -> String

@external(javascript, "./js.js", "window_location_href")
pub fn window_location_href() -> String
