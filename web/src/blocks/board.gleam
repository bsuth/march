import blocks/base_icon
import blocks/card
import core/engine/position.{type Position}
import core/engine/settings.{type Settings}
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import lib/player_color
import lib/theme.{type Theme}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

// -----------------------------------------------------------------------------
// Props / Events
// -----------------------------------------------------------------------------

pub fn prop_flipped(flipped: Bool) {
  attribute.property("flipped", json.bool(flipped))
}

pub fn prop_highlight_index(highlight_index: Option(Int)) {
  attribute.property(
    "highlight_index",
    json.nullable(highlight_index, json.int),
  )
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

pub fn on_board_focusout(message: message) {
  event.on("board_focusout", decode.success(message))
}

pub fn on_cell_click(handler: fn(Int) -> message) {
  event.on(
    "cell_click",
    ["detail"] |> decode.at(decode.int) |> decode.map(handler),
  )
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
    component.on_property_change("flipped", {
      decode.bool |> decode.map(PropsChangedFlipped)
    }),
    component.on_property_change("highlight_index", {
      decode.optional(decode.int) |> decode.map(PropsChangedHighlightIndex)
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
  Model(
    flipped: Bool,
    highlight_index: Option(Int),
    position: Position,
    settings: Settings,
    theme: Theme,
  )
}

fn init(_) {
  let settings = settings.classic()

  #(
    Model(
      flipped: False,
      highlight_index: option.None,
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
  PropsChangedFlipped(Bool)
  PropsChangedHighlightIndex(Option(Int))
  PropsChangedPosition(Position)
  PropsChangedSettings(Settings)
  PropsChangedTheme(Theme)

  OnCellClick(Int)
  OnDragStart
  OnFocusOut
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedFlipped(flipped) -> #(Model(..model, flipped:), effect.none())
    PropsChangedHighlightIndex(highlight_index) -> #(
      Model(..model, highlight_index:),
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

    OnCellClick(cell_index) -> #(
      model,
      event.emit("cell_click", json.int(cell_index)),
    )
    OnDragStart -> {
      echo "dragstart"
      #(model, effect.none())
    }
    OnFocusOut -> #(model, event.emit("board_focusout", json.null()))
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  let width = model.settings.board.width
  let height = model.settings.board.height

  html.div(
    [
      attribute.class("w-full h-full relative"),
      case model.flipped {
        True -> attribute.none()
        False -> attribute.class("rotate-180")
      },
    ],
    [
      html.div([attribute.class("absolute inset-0")], [
        html.div(
          [
            attribute.class("max-w-full max-h-full"),
            attribute.class("relative top-1/2 left-1/2 -translate-1/2"),
            attribute.style(
              "aspect-ratio",
              int.to_string(5 * width) <> "/" <> int.to_string(7 * height),
            ),
            attribute.tabindex(-1),
            event.on("focusout", decode.success(OnFocusOut)),
          ],
          [
            html.div(
              [
                attribute.class("grid gap-0"),
                attribute.class("border"),
                attribute.style(
                  "grid-template-columns",
                  "repeat(" <> int.to_string(width) <> ", 1fr)",
                ),
                attribute.style(
                  "grid-template-rows",
                  "repeat(" <> int.to_string(height) <> ", 1fr)",
                ),
              ],
              int.range(width * height - 1, -1, [], fn(cells, index) {
                cell_view(model, index) |> list.prepend(cells, _)
              }),
            ),
          ],
        ),
      ]),
    ],
  )
}

fn cell_view(model: Model, cell_index: Int) {
  html.div(
    [
      attribute.style("aspect-ratio", "5 / 7"),
      attribute.class("border"),
      attribute.class("cursor-pointer"),
      event.on("dragstart", decode.success(OnDragStart)),
      event.on_click(OnCellClick(cell_index)),
    ],
    [
      html.div(
        [
          attribute.class("w-full h-full"),
          attribute.class("flex justify-center items-center"),
          case model.flipped {
            True -> attribute.none()
            False -> attribute.class("-rotate-180")
          },
        ],
        [cell_content_view(model, cell_index)],
      ),
    ],
  )
}

fn cell_content_view(model: Model, cell_index: Int) {
  let width = model.settings.board.width
  let height = model.settings.board.height

  case dict.get(model.position, cell_index) {
    Ok(option.Some(card)) ->
      card.element([
        attribute.class("w-full h-full"),
        case option.Some(cell_index) == model.highlight_index {
          True ->
            attribute.style("box-shadow", "0 0 4px 4px var(--march-primary)")
          False -> attribute.none()
        },
        card.prop_card(card),
        card.prop_player_color(player_color.from_player_index(
          card.player_index,
          model.settings.doubles,
        )),
      ])

    _ if cell_index == 0 ->
      base_icon.element([
        base_icon.prop_player_color(player_color.Black),
        base_icon.prop_theme(model.theme),
        attribute.class("size-1/2"),
      ])

    _ if cell_index == width * height - 1 ->
      base_icon.element([
        base_icon.prop_player_color(player_color.White),
        base_icon.prop_theme(model.theme),
        attribute.class("size-1/2"),
      ])

    _ if cell_index == width - 1 && model.settings.doubles ->
      base_icon.element([
        base_icon.prop_player_color(player_color.LightRed),
        base_icon.prop_theme(model.theme),
        attribute.class("size-1/2"),
      ])

    _ if cell_index == width * { height - 1 } && model.settings.doubles ->
      base_icon.element([
        base_icon.prop_player_color(player_color.DarkRed),
        base_icon.prop_theme(model.theme),
        attribute.class("size-1/2"),
      ])

    _ -> element.none()
  }
}
