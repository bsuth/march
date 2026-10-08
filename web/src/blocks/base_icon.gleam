import gleam/dynamic/decode
import lib/player_color.{type PlayerColor}
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import phosphor

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_player_color(player_color: PlayerColor) {
  attribute.property("player_color", player_color.json(player_color))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-base-icon"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("player_color", {
      player_color.decoder() |> decode.map(PropsChangedPlayerColor)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(PropsChangedTheme)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(player_color: PlayerColor, theme: Theme)
}

fn init(_) {
  #(Model(player_color: player_color.Black, theme: theme.Light), effect.none())
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

pub type Message {
  PropsChangedPlayerColor(PlayerColor)
  PropsChangedTheme(Theme)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedPlayerColor(player_color) -> #(
      Model(..model, player_color:),
      effect.none(),
    )
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let #(icon, class) = case model.player_color, model.theme {
    player_color.Black, theme.Light -> #(
      phosphor.castle_turret_fill,
      "text-(--march-950)",
    )
    player_color.Black, theme.Dark -> #(
      phosphor.castle_turret_light,
      "text-(--march-950)",
    )
    player_color.White, theme.Light -> #(
      phosphor.castle_turret_light,
      "text-(--march-950)",
    )
    player_color.White, theme.Dark -> #(
      phosphor.castle_turret_fill,
      "text-(--march-950)",
    )
    player_color.LightRed, _ -> #(phosphor.castle_turret_fill, "text-red-200")
    player_color.DarkRed, _ -> #(phosphor.castle_turret_fill, "text-red-900")
  }

  icon([attribute.class("w-full h-full"), attribute.class(class)])
}
