import blocks/card
import engine/board.{type Board}
import engine/board/cell.{type Cell, Cell}
import engine/color.{type Color}
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option
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

pub fn prop_board(board: Board) {
  attribute.property("board", board.json(board))
}

pub fn prop_theme(theme: Theme) {
  attribute.property("theme", theme.json(theme))
}

pub fn prop_color(color: Color) {
  attribute.property("color", color.json(color))
}

pub fn on_cell_click(handler: fn(Cell) -> message) {
  event.on(
    "cell_click",
    ["detail"] |> decode.at(cell.decoder()) |> decode.map(handler),
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
    component.on_property_change("board", {
      board.decoder() |> decode.map(PropsChangedBoard)
    }),
    component.on_property_change("theme", {
      theme.decoder() |> decode.map(PropsChangedTheme)
    }),
    component.on_property_change("color", {
      color.decoder() |> decode.map(PropsChangedColor)
    }),
  ])
  |> lustre.register(element_name)
}

// -----------------------------------------------------------------------------
// Init
// -----------------------------------------------------------------------------

type Model {
  Model(board: Board, color: Color, theme: Theme)
}

fn init(_) {
  #(
    Model(board.new(4, 4), color: color.Black, theme: theme.Light),
    effect.none(),
  )
}

// -----------------------------------------------------------------------------
// Update
// -----------------------------------------------------------------------------

pub type Message {
  PropsChangedBoard(Board)
  PropsChangedColor(Color)
  PropsChangedTheme(Theme)

  CellClick(Cell)
}

fn update(model: Model, message: Message) {
  case message {
    PropsChangedBoard(board) -> #(Model(..model, board:), effect.none())
    PropsChangedColor(color) -> #(Model(..model, color:), effect.none())
    PropsChangedTheme(theme) -> #(Model(..model, theme:), effect.none())

    CellClick(cell) -> #(model, event.emit("cell_click", cell.json(cell)))
  }
}

// -----------------------------------------------------------------------------
// View
// -----------------------------------------------------------------------------

fn view(model: Model) {
  html.div([attribute.class("w-full h-full relative")], [
    html.div([attribute.class("absolute inset-0")], [
      html.div(
        [
          attribute.class("max-w-full max-h-full"),
          attribute.class("relative top-1/2 left-1/2 -translate-1/2"),
          attribute.style(
            "aspect-ratio",
            int.to_string(model.board.width)
              <> "/"
              <> int.to_string(model.board.height),
          ),
        ],
        [
          html.div(
            [
              attribute.class("grid gap-0"),
              attribute.style(
                "grid-template-columns",
                "repeat(" <> int.to_string(model.board.width) <> ", 1fr)",
              ),
              attribute.style(
                "grid-template-rows",
                "repeat(" <> int.to_string(model.board.height) <> ", 1fr)",
              ),
            ],
            int.range(
              0,
              model.board.width * model.board.height,
              [],
              fn(cells, index) {
                cell_view(
                  model,
                  model.board.width * model.board.height - 1 - index,
                )
                |> list.prepend(cells, _)
              },
            ),
          ),
        ],
      ),
    ]),
  ])
}

fn cell_view(model: Model, render_index: Int) {
  let white_base_index = board.get_base_index(model.board, color.White)

  let cell_index = case model.color {
    color.White -> render_index
    color.Black -> model.board.width * model.board.height - 1 - render_index
  }

  use cell <- yuzu.ok(dict.get(model.board.cells, cell_index), element.none())

  html.div(
    [
      attribute.class("aspect-square"),
      attribute.class("flex justify-center items-center"),
      attribute.class("border-b border-r"),
      attribute.class("cursor-pointer"),
      case render_index / model.board.width {
        0 -> attribute.class("border-t")
        _ -> attribute.none()
      },
      case render_index % model.board.width {
        0 -> attribute.class("border-l")
        _ -> attribute.none()
      },
      event.on_click(CellClick(cell)),
    ],
    [
      case cell, cell_index {
        Cell(_, _, option.Some(card)), _ ->
          card.element([attribute.class("w-full h-full"), card.prop_value(card)])

        _, 0 -> base_icon_view(color.Black, model.theme)

        _, _ if cell_index == white_base_index ->
          base_icon_view(color.White, model.theme)

        _, _ -> element.none()
      },
    ],
  )
}

fn base_icon_view(color: Color, theme: Theme) {
  let icon = case color, theme {
    color.White, theme.Light -> phosphor.castle_turret_light
    color.White, theme.Dark -> phosphor.castle_turret_fill
    color.Black, theme.Light -> phosphor.castle_turret_fill
    color.Black, theme.Dark -> phosphor.castle_turret_light
  }

  icon([attribute.class("size-1/2")])
}
