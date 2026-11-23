import blocks/card
import core/engine/card_art
import core/engine/position.{type Position}
import core/engine/settings.{type Settings}
import core/util
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
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

pub fn class(class: String) {
  attribute.property("class", json.string(class))
}

pub fn flipped(flipped: Bool) {
  attribute.property("flipped", json.bool(flipped))
}

pub fn highlight_index(highlight_index: Option(Int)) {
  attribute.property(
    "highlight_index",
    json.nullable(highlight_index, json.int),
  )
}

pub fn position(position: Position) {
  attribute.property("position", position.json(position))
}

pub fn settings(settings: Settings) {
  attribute.property("settings", settings.json(settings))
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
    component.on_property_change("class", {
      decode.string |> decode.map(PropsChangedClass)
    }),
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
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(
    class: String,
    flipped: Bool,
    highlight_index: Option(Int),
    position: Position,
    settings: Settings,
  )
}

fn init(_) {
  let settings = settings.classic()

  #(
    Model(
      class: "",
      flipped: False,
      highlight_index: option.None,
      position: position.new(settings.board),
      settings: settings,
    ),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

pub type Message {
  PropsChangedClass(String)
  PropsChangedFlipped(Bool)
  PropsChangedHighlightIndex(Option(Int))
  PropsChangedPosition(Position)
  PropsChangedSettings(Settings)

  OnCellClick(Int)
  OnFocusOut
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedClass(class) -> #(Model(..model, class:), effect.none())
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

    OnCellClick(cell_index) -> #(
      model,
      event.emit("cell_click", json.int(cell_index)),
    )
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
      attribute.class(model.class),
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

  let base_cell_player_index = case model.settings.doubles {
    _ if cell_index == 0 -> option.Some(0)
    False if cell_index == width * height - 1 -> option.Some(1)
    True if cell_index == width - 1 -> option.Some(1)
    True if cell_index == width * height - 1 -> option.Some(2)
    True if cell_index == width * { height - 1 } -> option.Some(3)
    _ -> option.None
  }

  case dict.get(model.position, cell_index), base_cell_player_index {
    Ok(option.Some(position_card)), _ ->
      card.element([
        attribute.class("w-full h-full"),
        card.class("w-full h-full object-fill"),
        card.variant(card.Front(position_card.face, position_card.suit)),
        model.settings.card_arts
          |> util.get_list_index(position_card.player_index)
          |> result.unwrap(card_art.DefaultBlack)
          |> card.card_art(),
        case option.Some(cell_index) == model.highlight_index {
          True ->
            attribute.style("box-shadow", "0 0 4px 4px var(--march-primary)")
          False -> attribute.none()
        },
      ])

    _, option.Some(base_cell_player_index) ->
      card.element([
        attribute.class("w-full h-full"),
        card.class("w-full h-full object-fill"),
        card.variant(card.Base),
        model.settings.card_arts
          |> util.get_list_index(base_cell_player_index)
          |> result.unwrap(card_art.DefaultBlack)
          |> card.card_art(),
      ])

    _, _ -> element.none()
  }
}
