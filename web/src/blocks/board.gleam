import blocks/card
import engine/board
import engine/position.{type Position}
import engine/settings.{type Settings, Settings}
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import lib/player_color.{type PlayerColor}
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import phosphor
import yuzu

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_player_index(player_index: Int) {
  attribute.property("player_index", json.int(player_index))
}

pub fn prop_position(position: Position) {
  attribute.property("position", position.json(position))
}

pub fn prop_settings(settings: Settings) {
  attribute.property("settings", settings.json(settings))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

pub fn on_click(handler: fn(Int) -> message) {
  event.on("click", ["detail"] |> decode.at(decode.int) |> decode.map(handler))
}

// -----------------------------------------------------------------------------
// Component
// -----------------------------------------------------------------------------

const element_name = "blocks-board"

pub fn element(attrs: List(Attribute(message))) {
  element.element(element_name, attrs, [])
}

pub fn register() {
  lustre.component(init, update, view, [
    component.on_property_change("player_index", {
      decode.int |> decode.map(PropsChangedPlayerIndex)
    }),
    component.on_property_change("position", {
      position.decoder() |> decode.map(PropsChangedPosition)
    }),
    component.on_property_change("settings", {
      settings.decoder() |> decode.map(PropsChangedSettings)
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
  Model(player_index: Int, position: Position, settings: Settings, theme: Theme)
}

fn init(_) {
  let settings = settings.classic()

  #(
    Model(
      player_index: 0,
      position: position.new(settings.board),
      settings: settings,
      theme: theme.Light,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

pub type Message {
  PropsChangedPlayerIndex(Int)
  PropsChangedPosition(Position)
  PropsChangedSettings(Settings)
  PropsChangedTheme(Theme)

  OnClick(Int)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedPlayerIndex(player_index) -> #(
      Model(..model, player_index:),
      effect.none(),
    )
    PropsChangedPosition(position) -> #(
      Model(..model, position:),
      effect.none(),
    )
    PropsChangedSettings(settings) -> #(
      Model(..model, settings:),
      effect.none(),
    )
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    OnClick(index) -> #(model, event.emit("click", json.int(index)))
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let width = model.settings.board.width
  let height = model.settings.board.height

  // TODO: rotate board based on player index

  html.div([attribute.class("w-full h-full relative")], [
    html.div([attribute.class("absolute inset-0")], [
      html.div(
        [
          attribute.class("max-w-full max-h-full"),
          attribute.class("relative top-1/2 left-1/2 -translate-1/2"),
          attribute.style(
            "aspect-ratio",
            int.to_string(width) <> "/" <> int.to_string(height),
          ),
        ],
        [
          html.div(
            [
              attribute.class("grid gap-0"),
              attribute.style(
                "grid-template-columns",
                "repeat(" <> int.to_string(width) <> ", 1fr)",
              ),
              attribute.style(
                "grid-template-rows",
                "repeat(" <> int.to_string(height) <> ", 1fr)",
              ),
            ],
            int.range(0, width * height, [], fn(cells, index) {
              cell_view(model, index) |> list.prepend(cells, _)
            }),
          ),
        ],
      ),
    ]),
  ])
}

fn cell_view(model: Model, cell_index: Int) {
  use cell <- yuzu.ok(dict.get(model.position, cell_index), element.none())

  // TODO: render doubles bases

  let width = model.settings.board.width
  let height = model.settings.board.height

  html.div(
    [
      attribute.class("aspect-square"),
      attribute.class("flex justify-center items-center"),
      attribute.class("border-b border-r"),
      attribute.class("cursor-pointer"),
      case cell_index / width {
        0 -> attribute.class("border-t")
        _ -> attribute.none()
      },
      case cell_index % width {
        0 -> attribute.class("border-l")
        _ -> attribute.none()
      },
      event.on_click(OnClick(cell_index)),
    ],
    [
      case cell, cell_index {
        option.Some(card), _ ->
          card.element([attribute.class("w-full h-full"), card.prop_value(card)])

        _, 0 -> base_icon_view(player_color.Black, model.theme)

        _, _ if cell_index == width * height - 1 ->
          base_icon_view(player_color.White, model.theme)

        _, _ -> element.none()
      },
    ],
  )
}

fn base_icon_view(player_color: PlayerColor, theme: Theme) {
  let icon = case player_color, theme {
    player_color.Black, theme.Light -> phosphor.castle_turret_fill
    player_color.Black, theme.Dark -> phosphor.castle_turret_light
    player_color.White, theme.Light -> phosphor.castle_turret_light
    player_color.White, theme.Dark -> phosphor.castle_turret_fill
    player_color.Red, _ -> phosphor.castle_turret_fill
    player_color.Blue, _ -> phosphor.castle_turret_fill
  }

  icon([attribute.class("size-1/2")])
}
