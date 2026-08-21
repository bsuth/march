import gleam/dynamic/decode
import gleam/json

pub type Theme {
  Light
  Dark
  // TODO: Support system theme.
  // Might need manual bindings to `window.matchMedia`.
  // See: https://tailwindcss.com/docs/dark-mode#with-system-theme-support
}

pub fn to_string(theme: Theme) {
  case theme {
    Light -> "light"
    Dark -> "dark"
  }
}

pub fn from_string(theme: String) {
  case theme {
    "dark" -> Ok(Dark)
    "light" -> Ok(Light)
    _ -> Error(theme)
  }
}

pub fn json(theme: Theme) {
  theme
  |> to_string()
  |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(theme_string) {
    case from_string(theme_string) {
      Ok(tile) -> decode.success(tile)
      Error(_) -> decode.failure(Light, "theme")
    }
  })
}

pub fn load() {
  load_() |> from_string()
}

@external(javascript, "./theme.js", "load")
pub fn load_() -> String

pub fn apply(theme: Theme) {
  theme |> to_string() |> apply_()
}

@external(javascript, "./theme.js", "apply")
fn apply_(theme: String) -> Nil

pub fn save(theme: Theme) {
  theme |> to_string() |> save_()
}

@external(javascript, "./theme.js", "save")
fn save_(theme: String) -> Nil
